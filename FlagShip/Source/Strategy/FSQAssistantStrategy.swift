//
//  FSQAssistantStrategy.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/04/2026.
//  Copyright © 2026 FlagShip. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
#endif

// MARK: - QA Assistant Strategy

/// Strategy that intercepts flag resolution and hit tracking for the QA Assistant.
/// QassistantStrategy, replacing Dart streams with NotificationCenter.
class FSQAssistantStrategy: FSDefaultStrategy {
    /// QA-forced flag modifications that override production values
    var qaModifications: [String: FSModification] = [:]

    /// Campaign IDs whose flags should return nil (default value)
    var hiddenCampaigns: Set<String> = []

    private var observers: [NSObjectProtocol] = []

    override init(_ pVisitor: FSVisitor) {
        super.init(pVisitor)
        setupObservers()
        FlagshipLogManager.Log(level: .ALL, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: initialized"))
    }

    deinit {
        cleanup()
    }

    // MARK: - Observer Lifecycle

    private func setupObservers() {
        let nc = NotificationCenter.default

        let modObs = nc.addObserver(forName: .fsQAModificationMessage, object: nil, queue: .main) { [weak self] note in
            guard let msg = note.userInfo?[FSQANotificationKey.message] as? FSQAModificationMessage else { return }
            self?.handleModificationMessage(msg)
        }

        let ctxObs = nc.addObserver(forName: .fsQAUserContextRequest, object: nil, queue: .main) { [weak self] _ in
            self?.handleUserContextRequest()
        }

        let actionObs = nc.addObserver(forName: .fsQACampaignAction, object: nil, queue: .main) { [weak self] note in
            guard let msg = note.userInfo?[FSQANotificationKey.message] as? FSQACampaignActionMessage else { return }
            self?.handleCampaignAction(msg)
        }

        observers = [modObs, ctxObs, actionObs]
        FlagshipLogManager.Log(level: .ALL, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: subscribed to QA notification streams"))
    }

    func cleanup() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        FlagshipLogManager.Log(level: .ALL, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: all observers removed"))
    }

    // MARK: - FSDelegateStrategy Overrides

    override func getFlagModification(_ key: String) -> FSModification? {
        let visitorMod = super.getFlagModification(key)

        // Flags from hidden campaigns return nil so the caller falls back to the default value
        if let mod = visitorMod, hiddenCampaigns.contains(mod.campaignId) {
            FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Override: '\(key)' is in hidden campaign \(mod.campaignId) — returning nil"))
            return nil
        }

        // Return the QA-forced value when present
        if let qaMod = qaModifications[key] {
            FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Override: using forced modification for '\(key)'"))
            return qaMod
        }

        return visitorMod
    }

    override func synchronize(onSyncCompleted: @escaping (FSFlagStatus, FetchFlagsRequiredStatusReason) -> Void) {
        super.synchronize { [weak self] status, reason in
            self?.sendCampaignsInfoToQA()
            onSyncCompleted(status, reason)
        }
    }

    override func updateContext(_ newContext: [String: Any]) {
        super.updateContext(newContext)
        let completeContext = visitor.context.getCurrentContext()
        FSQAMessageService.shared.broadcastUserContextUpdate(completeContext)
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: broadcasted updated visitor context"))
    }

    override func sendHit(_ hit: FSTrackingProtocol) {
        hit.visitorId = visitor.visitorId
        hit.anonymousId = visitor.anonymousId
        // hit.qa = true so the qa flag is included in the payload
        (hit as? FSTracking)?.qa = true
        FSQAMessageService.shared.broadcastHitEvent(payload: hit.bodyTrack)
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: intercepted hit — broadcasting to QA Assistant"))
        super.sendHit(hit)
    }

    override func activateFlag(_ flag: FSFlag) {
        // Build the activate hit, mark qa=true, broadcast before calling super
        if let modification = visitor.currentFlags[flag.key] {
            let activateHit = Activate(visitor.visitorId, visitor.anonymousId, modification: modification)
            var payload = activateHit.bodyTrack
            payload["t"] = FSTypeTrack.ACTIVATE.typeString
            payload["qa"] = true
            FSQAMessageService.shared.broadcastHitEvent(payload: payload)
            FlagshipLogManager.Log(level: .DEBUG, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: activate flag '\(flag.key)' — broadcasted to QA Assistant"))
        }
        super.activateFlag(flag)
    }

    // MARK: - Private Helpers

    private func sendCampaignsInfoToQA() {
        var seenVariations = Set<String>()
        var processedVariations: [[String: String]] = []

        for mod in visitor.currentFlags.values {
            let uniqueKey = "\(mod.campaignId)_\(mod.variationId)_\(mod.variationGroupId)"
            guard !seenVariations.contains(uniqueKey) else { continue }
            seenVariations.insert(uniqueKey)
            processedVariations.append([
                "campaignId": mod.campaignId,
                "variationId": mod.variationId,
                "variationGroupId": mod.variationGroupId
            ])
        }

        FSQAMessageService.shared.broadcastFetchedFlagIds(processedVariations)
        FSQAMessageService.shared.broadcastUserContextUpdate(visitor.context.getCurrentContext())
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: sent \(processedVariations.count) variation(s) and context to QA Assistant"))
    }

    private func handleModificationMessage(_ message: FSQAModificationMessage) {
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: received modification message for campaign '\(message.campaignId)'"))

        let flagsValue = message.variation.modifications["value"] as? [String: Any]

        if let flagsValue = flagsValue, !flagsValue.isEmpty {
            hiddenCampaigns.remove(message.campaignId)

            var changedFlags: [String] = []
            for (key, value) in flagsValue {
                let mod = FSModification(
                    campaignId: message.campaignId,
                    campaignName: message.campaignName,
                    variationGroupId: message.variationGroupId,
                    variationGroupName: message.variationGroupName,
                    variationId: message.variation.id,
                    variationName: message.variation.name,
                    isReference: message.variation.reference,
                    campaignType: message.campaignType,
                    slug: message.campaignSlug,
                    value: value
                )
                qaModifications[key] = mod
                changedFlags.append(key)
                FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("  QA override: \(key) = \(value)"))
            }

            FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: total QA modifications: \(qaModifications.count)"))
            notifyFlagChanges(changedFlags)
        } else {
            // Empty modifications — clear QA overrides for this campaign (unforce)
            clearCampaignModifications(message.campaignId)
        }
    }

    private func clearCampaignModifications(_ campaignId: String) {
        var removedKeys: [String] = []
        for (key, mod) in qaModifications where mod.campaignId == campaignId {
            removedKeys.append(key)
        }
        removedKeys.forEach { qaModifications.removeValue(forKey: $0) }
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: removed \(removedKeys.count) QA modification(s) for campaign \(campaignId)"))
        if !removedKeys.isEmpty {
            notifyFlagChanges(removedKeys)
        }
    }

    private func notifyFlagChanges(_ changedFlagKeys: [String]) {
        // Internal notification (for SDK-level listeners)
        NotificationCenter.default.post(
            name: .fsQAFlagChanges,
            object: nil,
            userInfo: [FSQANotificationKey.changedFlags: changedFlagKeys]
        )
        // Public callback visitor.onFlagUpdate
        visitor.onFlagUpdate?(changedFlagKeys)
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: notified \(changedFlagKeys.count) flag change(s)"))
    }

    private func handleCampaignAction(_ message: FSQACampaignActionMessage) {
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: campaign action '\(message.action)' for '\(message.campaignId)'"))
        switch message.action {
        case "hide":
            hideCampaign(message.campaignId)
        case "unhide":
            unhideCampaign(message.campaignId)
        default:
            FlagshipLogManager.Log(level: .WARNING, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: unknown campaign action '\(message.action)'"))
        }
    }

    private func hideCampaign(_ campaignId: String) {
        hiddenCampaigns.insert(campaignId)
        clearCampaignModifications(campaignId)

        let affected = visitor.currentFlags.filter { $0.value.campaignId == campaignId }.map { $0.key }
        if !affected.isEmpty { notifyFlagChanges(affected) }
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: campaign '\(campaignId)' is now hidden"))
    }

    private func unhideCampaign(_ campaignId: String) {
        let wasHidden = hiddenCampaigns.remove(campaignId) != nil
        guard wasHidden else { return }

        let affected = visitor.currentFlags.filter { $0.value.campaignId == campaignId }.map { $0.key }
        if !affected.isEmpty { notifyFlagChanges(affected) }
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: campaign '\(campaignId)' is now visible"))
    }

    private func handleUserContextRequest() {
        let context = visitor.context.getCurrentContext()
        FSQAMessageService.shared.broadcastUserContextUpdate(context)
        FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("QA Strategy: sent user context in response to request"))
    }
}
