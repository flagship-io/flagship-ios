//
//  FlagshipContextTest.swift
//  FlagshipTests
//
//  Created by Adel on 06/12/2021.
//

import XCTest
@testable import Flagship

class FlagshipContextTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPresetContext() {
        
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")
        
        let visitorCtx = Flagship.sharedInstance.newVisitor("aliasCtx").build()
        
        
         
        for itemCase in FlagshipContext.allCases{
            
           // visitorCtx.updatePresetContext(itemCase, "test")
            
            switch itemCase{
                
            case .LOCATION_LAT, .LOCATION_LONG:
                visitorCtx.updateContext(itemCase, 12.4)
                break
            case .DEV_MODE, .FIRST_TIME_INIT:
                visitorCtx.updateContext(itemCase, true)
                break
                
            case .CARRIER_NAME,.DEVICE_LOCALE,.DEVICE_TYPE,.DEVICE_MODEL,.LOCATION_CITY,.LOCATION_REGION,.IP,.OS_NAME,.OS_VERSION, .INTERNET_CONNECTION, .APP_VERSION_CODE, .APP_VERSION_NAME, .FLAGSHIP_VERSION, .INTERFACE_NAME,.LOCATION_COUNTRY:
                visitorCtx.updateContext(itemCase, "unitTest")
                break
            }
        }
        
        let currentCtx = visitorCtx.getContext()
        XCTAssertTrue(currentCtx[FlagshipContext.LOCATION_LAT.rawValue] as? Double == 12.4)
        XCTAssertTrue(currentCtx[FlagshipContext.FIRST_TIME_INIT.rawValue] as? Bool == true)
        XCTAssertTrue(currentCtx[FlagshipContext.APP_VERSION_NAME.rawValue] as? String == "unitTest")
    }



}
