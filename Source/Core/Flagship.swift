//
//  ABFlagShip.swift
//  Flagship
//
//  Created by Adel on 02/08/2019.
//

import Foundation

/**
 
 `FlagShip` class helps you run FlagShip on your native iOS app.
 
 */

public class Flagship: NSObject {

    /// This id is unique for the app
    internal(set) public var visitorId: String! {

        willSet {

        }didSet {

            self.service?.visitorId = visitorId
        }
    }

    /// This id used for the no logged session
    internal(set) public var anonymousId: String? {

        willSet {

        }didSet {
            self.service?.anonymousId = anonymousId
        }
    }

    /// Client Id
    internal var environmentId: String!

    // fsQueue
    let fsQueue = DispatchQueue(label: "com.flagship.queue", attributes: .concurrent)

    /// Current Context
    internal var context: FSContext!

    /// All Campaigns
    private var _campaigns: FSCampaigns!

    internal var campaigns: FSCampaigns! {

        get {
            return fsQueue.sync {

                _campaigns
            }
        }
        set {
            fsQueue.async(flags: .barrier) {

                self._campaigns = newValue
            }
        }
    }

    /// Service
    private var _service: ABService?

    internal var service: ABService? {

        get {
            return fsQueue.sync {

                _service
            }
        }
        set {
            fsQueue.async(flags: .barrier) {

                self._service = newValue
            }
        }
    }

    /// Enable Logs, By default the log is enabled
    @objc public var enableLogs: Bool = true

    /// Panic Button let you disable the SDK when needed
    private var _disabledSdk: Bool = false

    @objc public var disabledSdk: Bool {

        get {
            return fsQueue.sync {

                _disabledSdk
            }
        }
        set {
            fsQueue.async(flags: .barrier) {

                self._disabledSdk = newValue
            }
        }
    }

    internal var sdkModeRunning: FlagshipMode = .DECISION_API  // By default the sdk run with the decision mode
    

    /// Shared instance
    @objc public static let sharedInstance: Flagship = {

        let instance = Flagship()
        // setup code
        return instance
    }()

    /// Audience
    let audience: FSAudience!
    
    
    private var _isConsent: Bool = true
    
    internal var sdkState:FSState = FSState()
    
    @objc public var isConsent: Bool {

        get {
            return fsQueue.sync {

                _isConsent
            }
        }
        set {
            fsQueue.async(flags: .barrier) {
                
                // Check if the sdk is not disabled (panic mode)
                if (self._disabledSdk == false){
                    self._isConsent = newValue
                    /// See later for refractor or chekcing
                    self.sdkState.updateRgpd(self._isConsent ? RGPD.AUTHORIZE_TRACKING : RGPD.UNAUTHORIZE_TRACKING)
                    /// send Hit of consent
                    self._service?.sendHitConsent(_hasConsented: newValue)
                }
            }
        }
 
    }


    internal override init() {
        // init context
        self.context = FSContext()

        self.audience = FSAudience()
    }

    /**
     Start FlagShip
     
     @param envId String environmentId id for client
     
     @param apiKey String provided by abtasty apiKey
     
     @param visitorId String visitor id @optional
     
     @param FSConfig Object config @optional
     
     @param onStartDone The block to be invoked when sdk is ready
     */
    
    
    @objc public  func start( envId: String, apiKey: String, visitorId: String?, config: FSConfig = FSConfig(.DECISION_API), onStartDone:@escaping(FlagshipResult) -> Void) {

        // Check the environmentId
        if FSTools.chekcXidEnvironment(envId) {

            self.environmentId =   envId

        } else {
            
            onStartDone(.NotReady)
            return
        }

        /// Manage visitor id
        do {

            /// Before calling service manage the tuple
            if config.authenticated {

                self.visitorId = visitorId     /// when the authenticated is true , the visitor id should not be nil
                self.anonymousId = try FSTools.manageVisitorId(nil)
            } else {

                self.visitorId =  try FSTools.manageVisitorId(visitorId)
                self.anonymousId = nil
            }

        } catch {
            onStartDone(.NotReady)
            FSLogger.FSlog(String(format: "The visitor id is empty. The SDK Flagship is not ready "), .Campaign)
            return
        }
        /// Sservice with apiKey and Timeout
        self.service = ABService(self.environmentId, self.visitorId ?? "", self.anonymousId, apiKey, timeoutService: config.flagshipTimeOutRequestApi)

        // Set the préconfigured Context
        self.context.currentContext.merge(FSPresetContext.getPresetContextForApp()) { (_, new) in new }

        // Set all_users
        self.context.currentContext.updateValue("", forKey: ALL_USERS)

        // The current context is
        FSLogger.FSlog("The current context is : \(self.context.currentContext.description)", .Campaign)

        sdkModeRunning = config.mode
        // update consent in the start from config object
        _isConsent =  config.hasConsented;
        
        // update the state
        if isConsent {
            sdkState.updateRgpd(RGPD.AUTHORIZE_TRACKING)
            
            /// Send the keys/values context
            DispatchQueue(label: "flagship.contextKey.queue").async {

                self.service?.sendkeyValueContext(self.context.currentContext)
            }
        }else{
            sdkState.updateRgpd(RGPD.UNAUTHORIZE_TRACKING)
            self.service?.sendHitConsent(_hasConsented: isConsent)
        }

        switch sdkModeRunning {

        case .BUCKETING:
            onStartBucketing(onStartDone)
            break

        case .DECISION_API:
            onStartDecisionApi(onStartDone)
            break
        }
        // Purge data event
        DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute: DispatchWorkItem {
            self.service?.threadSafeOffline.flushStoredEvents()
        })

    }

    /**
     getCampaigns
     
     @param pBlock The block to be invoked when sdk receive campaign
     */
    internal func getCampaigns(onGetCampaign:@escaping(FlagshipError?) -> Void) {

        FSLogger.FSlog("Get Campaign .............", .Campaign)

        if self.service != nil {

            self.service?.getCampaigns(context.currentContext) { (campaigns, error) in

                if error == nil {

                    /// Check if the sdk is disabled
                    if let panic = campaigns?.panic {

                        if panic {

                            self.disabledSdk = true

                            FSLogger.FSlog(String(format: "The SDK Flagship disabled from the flagship account - panic mode"), .Campaign)

                            FSLogger.FSlog(String(format: "Default values will be returned by the getModification function"), .Campaign)

                        } else {

                            self.disabledSdk = false
                            // Set Campaigns
                            self.campaigns = campaigns
                            self.context.updateModification(campaigns)
                            FSLogger.FSlog(String(format: "The get Campaign are %@", campaigns.debugDescription), .Campaign)

                        }
                    }
                    /// Return wihtout error
                    onGetCampaign(.None)
                } else {

                    FSLogger.FSlog(String(format: "Error on get campaign", campaigns.debugDescription), .Campaign)
                    onGetCampaign(.GetCampaignError)
                }
            }
        } else {

            onGetCampaign(.GetCampaignError)
        }
    }

    /////////////////////////////////////// SHIP VALUES /////////////////////////////////////////////////

    /**
     Get Modification for boolean
     
     @param key associated with the modification
     
     @param default value returned when the key doesn’t match any modification value
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Boolean value
     
     */
    @objc public func getModification(_ key: String, defaultBool: Bool, activate: Bool = false) -> Bool {
        
        
        // Check if disabled (panic mode)
        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultBool
        }
        
        if sdkState.isAuthorized() && activate && self.campaigns != nil {
            // Activate
            self.service?.activateCampaignRelativetoKey(key, self.campaigns)
        }

        return context.readBooleanFromContext(key, defaultBool: defaultBool)
    }

    /**
     Get Modification for string
     
     @param key associated with the modification
     
     @param default value returned when the key doesn’t match any modification value
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return String value
     
     */
    @objc public func getModification(_ key: String, defaultString: String, activate: Bool = false) -> String {
        
        // Check if disabled
        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultString
        }

        if sdkState.isAuthorized() && activate && self.campaigns != nil {

            self.service?.activateCampaignRelativetoKey(key, self.campaigns)
        }
        return context.readStringFromContext(key, defaultString: defaultString)
    }

    /**
     Get Modification for Double
     
     @param key associated with the modification
     
     @param default value returned when the key doesn’t match any modification value
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Double value
     */
    @objc public func getModification(_ key: String, defaultDouble: Double, activate: Bool = false) -> Double {

        // Check if disabled
        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultDouble
        }

        if sdkState.isAuthorized() && activate && self.campaigns != nil {

            self.service?.activateCampaignRelativetoKey(key, self.campaigns)
        }
        return context.readDoubleFromContext(key, defaultDouble: defaultDouble)
    }

    /**
     Get Modification for Float
     
     @param key associated with the modification
     
     @param default value returned when the key doesn’t match any modification value
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Float value
     */
    @objc public func getModification(_ key: String, defaulfloat: Float, activate: Bool = false) -> Float {

        // Check if disabled
        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaulfloat
        }

        if sdkState.isAuthorized() && activate && self.campaigns != nil {

            self.service?.activateCampaignRelativetoKey(key, self.campaigns)
        }
        return context.readFloatFromContext(key, defaultFloat: defaulfloat)
    }

    /**
     Get Modification for the integer
     
     @param key associated with the modification
     
     @param default value returned when the key doesn’t match any modification value
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Int value
     
     */
    @objc public func getModification(_ key: String, defaultInt: Int, activate: Bool = false) -> Int {

        // Check if disabled
        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultInt
        }

        if sdkState.isAuthorized() && activate && self.campaigns != nil {

            self.service?.activateCampaignRelativetoKey(key, self.campaigns)
        }

        return context.readIntFromContext(key, defaultInt: defaultInt)
    }

    /**
     Get Modification for an array
     
     @param key associated with the modification
     
     @param default value returned when the key doesn’t match any modification value
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Array [Any]
     
     */

    @objc public func getModification(_ key: String, defaultArray: [Any], activate: Bool = false) ->[Any] {

        // Check if disabled
        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultArray
        }

        if sdkState.isAuthorized() && activate && self.campaigns != nil {

            self.service?.activateCampaignRelativetoKey(key, self.campaigns)
        }

        return self.context.readArrayFromContext(key, defaultArray: defaultArray)

    }

    /**
     Get Modification for Json (Dictionary)
     
     @param key associated with the modification
     
     @param default value returned when the key doesn’t match any modification value
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Dictionary<String,Any>, represent the json object
     
     */
    @objc public func getModification(_ key: String, defaultJson: [String: Any], activate: Bool = false) -> [String: Any] {

        // Check if disabled
        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultJson
        }

        if sdkState.isAuthorized() && activate && self.campaigns != nil {

            self.service?.activateCampaignRelativetoKey(key, self.campaigns)
        }

        return self.context.readJsonObjectFromContext(key, defaultDico: defaultJson)

    }
    
    /*
     Get modification info.  { “campaignId”: “xxxx”, “variationGroupId”: “xxxx“, “variationId”: “xxxx”, "isReference":true/false}
     
     @param key for associated  modification
     
     @return { “campaignId”: “xxxx”, “variationGroupId”: “xxxx“, “variationId”: “xxxx”, "isReference":true/false} or nil
     */

    @objc public func getModificationInfo(key: String) -> [String: Any]? {

        if self.campaigns != nil {

            return self.campaigns.getRelativekeyModificationInfosBis(key)
        }

        FSLogger.FSlog(" Any campaign found, to retreive the information's modification key", .Campaign) /// See later for the logs
        return nil
    }

    /**
     Activate Modifications values
     
     @key key which identifies the modification
     
     */

    @objc public func activateModification(key: String) {
        
        if (disabledSdk || !sdkState.isAuthorized()){
            FSLogger.FSlog("FlagShip not allowed to send hit", .Campaign)
            return
        }

        if self.campaigns != nil {

            self.service?.activateCampaignRelativetoKey(key, self.campaigns)
        }
    }

    /**
     Send Hits for tracking
     
     @param event Event Object (Page, Transaction, Item, Event)
     
     */
    public func sendHit<T: FSTrackingProtocol>(_ event: T) {
                
        if (disabledSdk || !sdkState.isAuthorized()){
            
            FSLogger.FSlog("FlagShip Not allowed to send hit", .Campaign)
            return

        }
 
        self.service?.sendTracking(event)
    }

    /// For Objective C Project, use the functions below to send Events
    /// See https://developers.flagship.io/ios/#hit-tracking

    /**
     Send Transaction event
     
     @param transacEvent : Transaction event
     
     */

    @objc public func sendTransactionEvent(_ transacEvent: FSTransaction) {

        if (disabledSdk || !sdkState.isAuthorized()) {
            FSLogger.FSlog("FlagShip disabled.....the event transaction will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(transacEvent)
    }

    /**
     Send Page event
     
     @param pageEvent : Page event
     
     */
    @objc public func sendScreenEvent(_ screenEvent: FSScreen) {

        if (disabledSdk || !sdkState.isAuthorized()) {
            FSLogger.FSlog("FlagShip disabled.....the event page will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(screenEvent)
    }

    /**
     Send Item event
     
     @param itemEvent : Item event
     
     */

    @objc public func sendItemEvent(_ itemEvent: FSItem) {

        if (disabledSdk || !sdkState.isAuthorized()){
            FSLogger.FSlog("FlagShip disabled.....the event item will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(itemEvent)
    }

    /**
     Send event track
     
     @param eventTrack : track event
     
     */
    @objc public func sendEventTrack(_ eventTrack: FSEvent) {
        
        if (disabledSdk || !sdkState.isAuthorized()) {
            FSLogger.FSlog("FlagShip disabled.....the event track will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(eventTrack)
    }
    
    
    
    
    
    
  
}
