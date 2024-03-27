//
//  FSVisitor+Campaigns.swift
//  Flagship
//
//  Created by Adel on 01/10/2021.
//

import Foundation

extension FSVisitor {
 
    func updateFlagsAndAssignedHistory(_ newFlags: [String: FSModification]?) {
 
        if let aNewFlag = newFlags {
            /// Clean the current flag
            currentFlags.removeAll()
            currentFlags = aNewFlag
            
            // update the assignation history
            self.updateAssignedHistory(aNewFlag)
        }
    }
 
    
    func updateAssignedHistory(_ newFlags: [String: FSModification]) {
        let groupIdkeys = assignedVariationHistory.keys
        newFlags.forEach { (_: String, value: FSModification) in
            if !groupIdkeys.contains(value.variationGroupId) {
                assignedVariationHistory.merge([value.variationGroupId: value.variationId]) { _, new in new }
            }
        }
    }
    
 
    func mergeCachedVisitor(_ cachedVisitor: FSCacheVisitor) {
        // Retreive cached flags and Merge in the visitor instance
        var cachedFlgs: [String: FSModification] = [:]
        for item in cachedVisitor.data?.campaigns ?? [] {
            cachedFlgs.merge(item.getFlagsFromCachedCampaign()) { _, new in new }
        }
        /// Merge with current Flags for visitor instance
        if !cachedFlgs.isEmpty {
            self.currentFlags.merge(cachedFlgs) { _, new in new }
        }
        /// Retreive the context and Merge it
        if let cachedContext = cachedVisitor.data?.context {
           // self.context.mergeContext(cachedContext) /// To do later
        }

        // Update the reason
        self.requiredFetchReason = .READ_FROM_CACHE
        // Update the state
        self.fetchStatus = .FETCH_REQUIRED
    }
}
