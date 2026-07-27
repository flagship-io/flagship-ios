// import Foundation
//
//// MARK: - Notification names
//
// public extension Notification.Name {
//    static let qaAssistantDidStart    = Notification.Name("com.abtasty.qa.didStart")
//    static let qaAssistantDidStop     = Notification.Name("com.abtasty.qa.didStop")
//    static let qaUserContextDidUpdate = Notification.Name("com.abtasty.qa.userContextDidUpdate")
//    static let qaUserContextRequest   = Notification.Name("com.abtasty.qa.userContextRequest")
//    static let qaHitEventReceived     = Notification.Name("com.abtasty.qa.hitEventReceived")
//    static let qaVariationsDidUpdate  = Notification.Name("com.abtasty.qa.variationsDidUpdate")
// }
//
//// MARK: - Payload keys
//
// public enum QANotificationKey {
//    public static let userContext = "userContext"
//    public static let hitEvent   = "hitEvent"
//    public static let variations = "variations"
// }
//
//// MARK: - QAMessageService
//
///// Shared message bus between the Flagship SDK and ABTastyQAssistant.
///// Flagship SDK posts events (hits, context, variations); ABTastyQAssistant listens.
///// ABTastyQAssistant posts lifecycle events (start/stop); Flagship SDK listens.
// public final class QAMessageService {
//
//    public static let shared = QAMessageService()
//    private init() {}
//
//    // MARK: - Broadcast (Flagship SDK → QA Assistant)
//
//    public func broadcastHitEvent(_ event: QAHitEvent) {
//        post(.qaHitEventReceived, userInfo: [QANotificationKey.hitEvent: event])
//    }
//
//    public func broadcastUserContextUpdate(_ context: [String: Any]) {
//        post(.qaUserContextDidUpdate, userInfo: [QANotificationKey.userContext: context])
//    }
//
//    public func broadcastVariationsUpdate(_ data: [String: Any]) {
//        post(.qaVariationsDidUpdate, userInfo: [QANotificationKey.variations: data])
//    }
//
//    // MARK: - Broadcast (QA Assistant → Flagship SDK)
//
//    public func broadcastStartQAAssistant() {
//        post(.qaAssistantDidStart)
//        print("📢 Flagship SDK: QA Assistant started")
//    }
//
//    public func broadcastStopQAAssistant() {
//        post(.qaAssistantDidStop)
//        print("📢 Flagship SDK: QA Assistant stopped")
//    }
//
//    public func broadcastUserContextRequest() {
//        post(.qaUserContextRequest)
//    }
//
//    // MARK: - Subscribe / unsubscribe
//
//    @discardableResult
//    public func observe(_ name: Notification.Name,
//                        on queue: OperationQueue = .main,
//                        using handler: @escaping (Notification) -> Void) -> NSObjectProtocol {
//        return NotificationCenter.default.addObserver(
//            forName: name, object: nil, queue: queue, using: handler
//        )
//    }
//
//    public func remove(_ token: NSObjectProtocol) {
//        NotificationCenter.default.removeObserver(token)
//    }
//
//    // MARK: - Private
//
//    private func post(_ name: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
//        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
//    }
// }
//

// MARK: - QAHitEvent

public struct QAHitEvent {
    public let hitType: String
    public let payload: [String: Any]
    public let timestamp: Date

    public init(hitType: String, payload: [String: Any], timestamp: Date = Date()) {
        self.hitType = hitType
        self.payload = payload
        self.timestamp = timestamp
    }

    public var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: timestamp)
    }
}

import Foundation

// MARK: - QA Message Models

public struct FSQAVariation {
    public let id: String
    public let name: String
    public let reference: Bool
    /// Raw modifications dict: { "type": "Flag", "value": { "flagKey": flagValue } }
    public let modifications: [String: Any]

    public init(id: String, name: String, reference: Bool, modifications: [String: Any]) {
        self.id = id; self.name = name; self.reference = reference; self.modifications = modifications
    }
}

public struct FSQAModificationMessage {
    public let campaignId: String
    public let campaignName: String
    public let campaignType: String
    public let campaignSlug: String
    public let variationGroupId: String
    public let variationGroupName: String
    public let variation: FSQAVariation

    public init(campaignId: String, campaignName: String, campaignType: String, campaignSlug: String,
                variationGroupId: String, variationGroupName: String, variation: FSQAVariation) {
        self.campaignId = campaignId; self.campaignName = campaignName; self.campaignType = campaignType
        self.campaignSlug = campaignSlug; self.variationGroupId = variationGroupId
        self.variationGroupName = variationGroupName; self.variation = variation
    }
}

public struct FSQACampaignActionMessage {
    /// "hide" or "unhide"
    public let action: String
    public let campaignId: String

    public init(action: String, campaignId: String) {
        self.action = action; self.campaignId = campaignId
    }
}

// MARK: - QA Message Service

public extension Notification.Name {
    // Define a notification for when the QA Assistant starts, so the SDK can react (e.g., prepare to accept overrides)
    static let qaAssistantStarted = Notification.Name("com.abtasty.qa.Started")
    // Define a notification for when the QA Assistant stops, so the SDK can react (e.g., clear overrides)
    static let qaAssistantStoped = Notification.Name("com.abtasty.qa.Stoped")
    /// Posted by the QA Assistant to force flag modifications
    static let fsQAModificationMessage = Notification.Name("FSQAModificationMessage")
    /// Posted by the QA Assistant to request the current visitor context
    static let fsQAUserContextRequest = Notification.Name("FSQAUserContextRequest")
    /// Posted by the QA Assistant to hide/unhide a campaign
    static let fsQACampaignAction = Notification.Name("FSQACampaignAction")
    /// Posted by the SDK to broadcast fetched campaign/variation IDs to QA Assistant
    static let fsQABroadcastFetchedFlags = Notification.Name("FSQABroadcastFetchedFlags")
    /// Posted by the SDK to broadcast visitor context updates to QA Assistant
    static let fsQABroadcastUserContext = Notification.Name("FSQABroadcastUserContext")
    /// Posted by the SDK to broadcast hit events to QA Assistant
    static let fsQABroadcastHitEvent = Notification.Name("FSQABroadcastHitEvent")
    /// Posted by the SDK when QA flag overrides change
    static let fsQAFlagChanges = Notification.Name("FSQAFlagChanges")
    /// Posted when the QA Assistant has successfully preloaded its bucketing configuration
    static let fsQABroadcastStartQAAssistant = Notification.Name("FSQABroadcastStartQAAssistant")
}

/// Notification userInfo keys
public enum FSQANotificationKey {
    public static let message = "message"
    public static let variations = "variations"
    public static let context = "context"
    public static let payload = "payload"
    public static let changedFlags = "changedFlags"
}

/// Singleton service bridging the SDK and the QA Assistant via NotificationCenter.
/// The QA Assistant app posts inbound notifications; the SDK posts outbound ones.
public class FSQAMessageService {
    public static let shared = FSQAMessageService()
    private init() {}

    public func broadcastFetchedFlagIds(_ fetchedFlagIds: [[String: String]]) {
        NotificationCenter.default.post(
            name: .fsQABroadcastFetchedFlags,
            object: nil,
            userInfo: [FSQANotificationKey.variations: fetchedFlagIds]
        )
    }

    public func broadcastUserContextUpdate(_ context: [String: Any]) {
        NotificationCenter.default.post(
            name: .fsQABroadcastUserContext,
            object: nil,
            userInfo: [FSQANotificationKey.context: context]
        )
    }

    public func broadcastHitEvent(payload: [String: Any]) {
        NotificationCenter.default.post(
            name: .fsQABroadcastHitEvent,
            object: nil,
            userInfo: [FSQANotificationKey.payload: payload]
        )
    }

    public func broadcastStartQAAssistant() {
        NotificationCenter.default.post(name: .qaAssistantStarted, object: nil)
    }

    public func broadcastStopQAAssistant() {
        NotificationCenter.default.post(name: .qaAssistantStoped, object: nil)
    }

    public func broadcastUserContextRequest() {
        NotificationCenter.default.post(name: .fsQAUserContextRequest, object: nil)
    }

    // MARK: - QA Actions (QA Assistant → SDK)

    public func hideCampaign(_ campaignId: String) {
        let msg = FSQACampaignActionMessage(action: "hide", campaignId: campaignId)
        NotificationCenter.default.post(name: .fsQACampaignAction, object: nil, userInfo: [FSQANotificationKey.message: msg])
    }

    public func unhideCampaign(_ campaignId: String) {
        let msg = FSQACampaignActionMessage(action: "unhide", campaignId: campaignId)
        NotificationCenter.default.post(name: .fsQACampaignAction, object: nil, userInfo: [FSQANotificationKey.message: msg])
    }

    public func sendModification(_ message: FSQAModificationMessage) {
        NotificationCenter.default.post(name: .fsQAModificationMessage, object: nil, userInfo: [FSQANotificationKey.message: message])
    }

    @discardableResult
    public func observe(_ name: Notification.Name,
                        on queue: OperationQueue = .main,
                        using handler: @escaping (Notification) -> Void) -> NSObjectProtocol
    {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: queue, using: handler)
    }

    public func remove(_ token: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(token)
    }
}
