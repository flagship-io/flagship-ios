//
//  FSOfflineTrackingTest.swift
//  FlagshipTests
//
//  Created by Adel on 01/04/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSOfflineTrackingTest: XCTestCase {
    
    
    var offlineTrack:FSOfflineTracking!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
        self.offlineTrack = FSOfflineTracking( ABService("clientId", "userId","aid1", ""))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        
        offlineTrack = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testflushNoStoredEvents(){
        
        self.offlineTrack.flushStoredEvents()
    }
    
    
    
    /// Test Save event
    func testSaveEvent(){
        
        self.offlineTrack.saveEvent(FSEvent(eventCategory: .Action_Tracking, eventAction: "savedEvent"))
    }
    

    
    
    /// Test flush  with stored event
    func testFlushStoredEvents(){
        
        //// Save Event Action track
        self.offlineTrack.saveEvent(FSEvent(eventCategory: .Action_Tracking, eventAction: "savedEvent"))

        /// Save User engagment
        self.offlineTrack.saveEvent(FSEvent(eventCategory: .User_Engagement, eventAction: "savedEvent"))
        
        /// Save transaction
        self.offlineTrack.saveEvent(FSTransaction(transactionId: "id", affiliation: "savedAffiliation"))
        
        /// Save item
        self.offlineTrack.saveEvent(FSItem(transactionId: "id", name: "savedItem", code: "code"))
        
        ///  save page
        self.offlineTrack.saveEvent(FSPage("Savedpage"))
        
        
        /// Flush Stored events
        self.offlineTrack.flushStoredEvents()
    }
    
    
    
    func testSaveActiavte(){
        
        let infosToSave = ["vaid": "idVaid" , "caid":"idCaid","visitorId":"vid","clientId":"cid"]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: infosToSave, options:[])
            self.offlineTrack.saveActivateEvent(data)
        }catch{
            
            /// Error ..
        }
    }
    
    
    func testGetAllBodyTrackFromDisk(){
        
        self.offlineTrack.getAllBodyTrackFromDisk()
    }
    
    
    
    

}
