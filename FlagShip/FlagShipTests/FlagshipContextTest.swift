//
//  FlagshipContextTest.swift
//  FlagshipTests
//
//  Created by Adel on 06/12/2021.
//

@testable import Flagship
import XCTest

class FlagshipContextTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPresetContext() {
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")

        let visitorCtx = Flagship.sharedInstance.newVisitor(visitorId: "aliasCtx", hasConsented: true).build()

        let currentFSCtx = visitorCtx.getContext()
        XCTAssertTrue(currentFSCtx[FlagshipContext.FS_USERS.rawValue] as? String == "aliasCtx")
        XCTAssertTrue(currentFSCtx[FlagshipContext.FS_Client.rawValue] as? String == "iOS")
        XCTAssertTrue(currentFSCtx[FlagshipContext.FS_VERSION.rawValue] as? String == FlagShipVersion)
        XCTAssertTrue(currentFSCtx[FlagshipContext.DEVICE_TYPE.rawValue] as? String == "Mobile")

        for itemCase in FlagshipContext.allCases {
            // visitorCtx.updatePresetContext(itemCase, "test")

            switch itemCase {
            case .LOCATION_LAT, .LOCATION_LONG:
                visitorCtx.updateContext(itemCase, 12.4)
            case .DEV_MODE, .FIRST_TIME_INIT:
                visitorCtx.updateContext(itemCase, true)

            case .CARRIER_NAME, .DEVICE_LOCALE, .DEVICE_TYPE, .DEVICE_MODEL, .LOCATION_CITY, .LOCATION_REGION, .IP, .OS_NAME, .OS_VERSION_CODE, .INTERNET_CONNECTION, .APP_VERSION_CODE, .APP_VERSION_NAME, .FLAGSHIP_VERSION, .INTERFACE_NAME, .LOCATION_COUNTRY, .OS_VERSION_NAME, .OS_VERSION, .FS_Client, .FS_VERSION, .FS_USERS:
                visitorCtx.updateContext(itemCase, "unitTest")
            }
        }

        let currentCtx = visitorCtx.getContext()
        XCTAssertTrue(currentCtx[FlagshipContext.LOCATION_LAT.rawValue] as? Double == 12.4)
        XCTAssertTrue(currentCtx[FlagshipContext.FIRST_TIME_INIT.rawValue] as? Bool == true)
        XCTAssertTrue(currentCtx[FlagshipContext.APP_VERSION_NAME.rawValue] as? String == "unitTest")
    }

    func testUpdateCtxFetch() {
        let expectationSync = XCTestExpectation(description: "update-context")
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "123", config: FSConfigBuilder().Bucketing().build())

        var u1 = Flagship.sharedInstance.newVisitor(visitorId: "123", hasConsented: true).withContext(context: ["key2": "val2"]).build()
        // Should be TRUE
        XCTAssertTrue(u1.context.needToUpload)
        u1.fetchFlags {
            XCTAssertFalse(u1.context.needToUpload)
            expectationSync.fulfill()
            u1.updateContext(["key2": "val2"])
            XCTAssertFalse(u1.context.needToUpload)
            u1.updateContext(["key2": "val2Bis"])
            XCTAssertTrue(u1.context.needToUpload)
        }
        wait(for: [expectationSync], timeout: 5.0)
    }

    func testEqualContext() {
        let ctx = FSContext(["key": "val", "keyInt": 12, "keyFloat": 12.5, "keyDouble": 20.0, "keyBool": true], visitorId: "123")

        XCTAssertTrue(ctx.isContextUnchanged([ALL_USERS: "", "key": "val", "keyInt": 12, "keyFloat": 12.5, "keyDouble": 20.0, "keyBool": true, "fs_users": "123"]))
        XCTAssertFalse(ctx.isContextUnchanged([ALL_USERS: "", "key": "valBis", "keyInt": 12, "keyFloat": 12.5, "keyDouble": 20.0, "keyBool": true, "fs_users": "123"]))
        XCTAssertFalse(ctx.isContextUnchanged([ALL_USERS: "", "key": "val", "keyInt": 13, "keyFloat": 12.5, "keyDouble": 20.0, "keyBool": true, "fs_users": "123"]))
        XCTAssertFalse(ctx.isContextUnchanged([ALL_USERS: "", "key": "val", "keyInt": 12, "keyFloat": 12.54, "keyDouble": 20.0, "keyBool": true, "fs_users": "123"]))
        XCTAssertFalse(ctx.isContextUnchanged([ALL_USERS: "", "key": "val", "keyInt": 12, "keyFloat": 12.5, "keyDouble": 20.01, "keyBool": true, "fs_users": "123"]))
        XCTAssertFalse(ctx.isContextUnchanged([ALL_USERS: "", "key": "val", "keyInt": 12, "keyFloat": 12.5, "keyDouble": 20.0, "keyBool": false, "fs_users": "123"]))
        XCTAssertFalse(ctx.isContextUnchanged([ALL_USERS: "", "key": "val", "keyInt": 12, "keyFloat": 12.5, "keyDouble": 20.0, "keyBool": true, "otherKey": "otherVal", "fs_users": "123"]))
        ctx.clearContext()
        XCTAssertFalse(ctx.isContextUnchanged([ALL_USERS: "", "key": "val", "keyInt": 12, "keyFloat": 12.5, "keyDouble": 20.0, "keyBool": true]))
    }
}
