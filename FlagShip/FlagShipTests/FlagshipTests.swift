//
//  FlagshipTests.swift
//  FlagshipTests
//
//  Created by Adel on 14/10/2021.
//

import XCTest

@testable import Flagship

class FlagshipTests: XCTestCase {

    override func setUpWithError() throws {

    }
    
    
    func testStart(){
        
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")
        XCTAssert(Flagship.sharedInstance.envId == "gk87t3jggr10c6l6sdob")
        XCTAssert(Flagship.sharedInstance.apiKey == "apiKey")
        XCTAssert(Flagship.sharedInstance.currentStatus == .READY)
        
        XCTAssert(Flagship.sharedInstance.currentConfig.logLevel == .ALL)
        XCTAssert(Flagship.sharedInstance.currentConfig.mode == .DECISION_API)
        XCTAssert(Flagship.sharedInstance.currentConfig.timeout == 2)

    }
    
    
    func testStartWithConfig(){
        
        let fsConfig = FSConfigBuilder().DecisionApi().withTimeout(12).build()
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey", config: fsConfig)
        XCTAssert(Flagship.sharedInstance.envId == "gk87t3jggr10c6l6sdob")
        XCTAssert(Flagship.sharedInstance.apiKey == "apiKey")
        XCTAssert(Flagship.sharedInstance.currentStatus == .READY)
        
        XCTAssert(Flagship.sharedInstance.currentConfig.logLevel == .ALL)
        XCTAssert(Flagship.sharedInstance.currentConfig.mode == .DECISION_API)
        XCTAssert(Flagship.sharedInstance.currentConfig.timeout == 12/1000)

    }
    
    func testLogManager(){
        
        let customLoger = FSLogManager()
        customLoger.level = .WARNING
        customLoger.onLog(level: .DEBUG, tag: "testTag", message: "testMsg")
       XCTAssertTrue( customLoger.getLevel() == .WARNING)
    }

}
