//
//  FSContextTest.swift
//  FlagshipTests
//
//  Created by Adel on 04/03/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSContextTest: XCTestCase {
    
    var serviceTest:ABService!
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let sessionTest = URLSession.init(configuration: configuration)
        serviceTest = ABService("idClient", "isVisitor", "apiKey")
        
        /// Set our mock session into service
        serviceTest.sessionService = sessionTest
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
    //// test modification
    
    func testBoolean(){
        
        XCTAssert(Flagship.sharedInstance.getModification("aaaaa", defaultBool: true, activate: true))
    }
    
    
    func testdouble(){
        
        let result = Flagship.sharedInstance.getModification("doubleKey", defaultDouble: 122232323232323232, activate: true)
        
        XCTAssert(result == 122232323232323232)
    }
    
    
    func testFloat(){
        
        let result = Flagship.sharedInstance.getModification("floatKey", defaulfloat: 12.4, activate: true)
        
        XCTAssert(result == 12.4)
    }
    
    func testInt(){
        
        let result = Flagship.sharedInstance.getModification("intKey", defaultInt: 1, activate: true)
        
        XCTAssert(result == 1)
    }
    
    func testString(){
        
        let result = Flagship.sharedInstance.getModification("key", defaultString: "default", activate: true)
        
        XCTAssert(result == "default")
    }
    
    func testArray(){
        
        
        let result = Flagship.sharedInstance.getModification("key", defaultArray: [],activate: true)
        
        XCTAssert(result.count == 0)
        
        
        let resultA = Flagship.sharedInstance.getModification("keyA", defaultArray: ["val1"],activate: true)
        
        XCTAssert(resultA.count == 1)
        
        
    }
    
    func testJson(){
        
        let result = Flagship.sharedInstance.getModification("key", defaultJson:["key":"val1"],activate: true)
        
        let resultString = result["key"] as! String
        
        XCTAssert(resultString == "val1")
    }
    
    
    
    
    func testUpdateContext(){
        
        let values:[String:Any] = ["k1":"Val1", "k2":12,  "k3":true , "k4":0.4, "k5":2.01212121212121212121212121212121212121212, "k6":0.1111]
        
        for item in values{
            
            
            if (item.value.self is Int){
                Flagship.sharedInstance.updateContext(item.key, item.value as! Int)
                
            }else if (item.value.self is Double){
                Flagship.sharedInstance.updateContext(item.key, item.value as! Double)
                
                
            }else if (item.value.self is String){
                Flagship.sharedInstance.updateContext(item.key, item.value as! String)
                
            }else {
                
                //////
            }
            /// update dico
            Flagship.sharedInstance.updateContext(values)
        }
        
        
        //  let values:[String:Any] = ["k1":"Val1", "k2":12,  "k3":true , "k4":12.4]
        
        for item in values{
            
            if (item.value.self is Int){
                
                if let valToTest =  Flagship.sharedInstance.context.currentContext[item.key] as? Int{
                    
                    XCTAssertTrue(valToTest == 12)

                }
                
            }else if ( item.value.self is Float){
                if let valToTest =  Flagship.sharedInstance.context.currentContext[item.key] as? Float{
                    
                    XCTAssertTrue(valToTest == 12.4)

                }
                
            }else if (item.value.self is String){
                if let valToTest =  Flagship.sharedInstance.context.currentContext[item.key] as? String{
                    
                    XCTAssertTrue(valToTest == "Val1")
                }
                
            }else if (item.value.self is Bool) {
                
                if let valToTest =  Flagship.sharedInstance.context.currentContext[item.key] as? Bool{
                    
                    XCTAssertTrue(valToTest)

                }
                
            }else{
                ///////////
            }
            
            
        }
        
        Flagship.sharedInstance.context.removeKeyFromContext("")
        Flagship.sharedInstance.context.removeKeyFromContext("K1")
        Flagship.sharedInstance.context.cleanContext()
        Flagship.sharedInstance.context.cleanModification()
        
    }
    
    
    func testUpdateContextWhenDisabled(){
        
        Flagship.sharedInstance.disabledSdk = true
        
        Flagship.sharedInstance.updateContext(["disabled": "disable"])
        
        XCTAssertNil(Flagship.sharedInstance.context.currentContext["disabled"])
        
       
        Flagship.sharedInstance.updateContext(configuredKey: .APP_VERSION_NAME, value: "testDisable")
        
        
        XCTAssertFalse(Flagship.sharedInstance.context.currentContext["sdk_versionName"] as? String == "testDisable")

        
        Flagship.sharedInstance.disabledSdk = false

    }
    
    
    func testPresetContext(){
        
        Flagship.sharedInstance.updateContext(configuredKey: .APP_VERSION_CODE, value: 232323)
    }
    
    
    func testSyncForApi(){
        
        let expectation = self.expectation(description: #function)
        
        
        Flagship.sharedInstance.synchronizeModifications { (result) in
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    func testSyncWithoutVisitor(){
        
        /// Prepare ...
        Flagship.sharedInstance.service = ABService("", "alias", "apikey")
        Flagship.sharedInstance.visitorId = nil
        
        let bucketManager:FSBucketManager = FSBucketManager()
        
        let expectation = self.expectation(description: #function)
        
        do {
            
            let testBundle = Bundle(for: type(of: self))
            
            guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else { return  }
            
            let data = try Data(contentsOf: path, options:.alwaysMapped)
            
            FSCacheManager().saveBucketScriptInCache(data) /// save script in cache

            let bucketObject = try JSONDecoder().decode(FSBucket.self, from: data)
            
            let camps = bucketManager.bucketVariations("alias", bucketObject) //// match the variation
            
            print(camps ?? "")
            
            Flagship.sharedInstance.sdkModeRunning = .BUCKETING /// set the mode
            
            Flagship.sharedInstance.synchronizeModifications { (result) in
                
                expectation.fulfill()
                XCTAssertTrue(result == .NotReady)
             }
            waitForExpectations(timeout: 10)
            
            
        }catch{
            
            print("error")
        }
    }
    
    
    func testSyncWithPanic(){
        
        let expectation = self.expectation(description: #function)

        Flagship.sharedInstance.disabledSdk = true
        
        Flagship.sharedInstance.synchronizeModifications { (result) in
            
            XCTAssertTrue(result == .Disabled)
            Flagship.sharedInstance.disabledSdk = false
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    
    func testSyncForBucket(){
        
        let expectation = self.expectation(description: #function)
        
        Flagship.sharedInstance.sdkModeRunning = .BUCKETING
        
        Flagship.sharedInstance.synchronizeModifications { (result) in
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
    
    
    func testGetVisitorContext(){
        
        Flagship.sharedInstance.context.addStringCtx("testGetCtx", "val")

        let dico = Flagship.sharedInstance.getVisitorContext()
        
        XCTAssertTrue(dico.keys.contains("testGetCtx"))
        
        if let ret = dico["testGetCtx"] as? String{
            
            XCTAssertTrue(ret == "val")
        }
        
        
    }
}

