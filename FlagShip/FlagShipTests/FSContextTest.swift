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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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
        
        let values:[String:Any] = ["k1":"Val1", "k2":12,  "k3":true , "k4":0.4, "k5":2.01212121212121212121212121212121212121212]
        
        for item in values{
            
            
            if (item.value.self is Int){
                Flagship.sharedInstance.updateContext(item.key, item.value as! Int)

            }else if ( item.value.self is Float){
                 Flagship.sharedInstance.updateContext(item.key, item.value as! Float)
 
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
                
                let valToTest =  Flagship.sharedInstance.context.currentContext[item.key] as! Int
                XCTAssertTrue(valToTest == 12)
                
            }else if ( item.value.self is Float){
                 let valToTest =  Flagship.sharedInstance.context.currentContext[item.key] as! Float
                XCTAssertTrue(valToTest == 12.4)
                
            }else if (item.value.self is String){
                  let valToTest =  Flagship.sharedInstance.context.currentContext[item.key] as! String
                 XCTAssertTrue(valToTest == "Val1")
                
            }else if (item.value.self is Bool) {
                
                 let valToTest =  Flagship.sharedInstance.context.currentContext[item.key] as! Bool
                XCTAssertTrue(valToTest)
                
            }else{
                ///////////
            }
            
     
        }
        
        
        
        Flagship.sharedInstance.context.removeKeyFromContext("")
        Flagship.sharedInstance.context.removeKeyFromContext("K1")
        Flagship.sharedInstance.context.cleanContext()
        Flagship.sharedInstance.context.cleanModification()

        
        
    }
    
    
    func testPresetContext(){
        
        Flagship.sharedInstance.updateContext(configuredKey: .APP_VERSION_CODE, value: 232323)
    }
    
    
    func testSync(){
        
        let expectation = self.expectation(description: #function)
        
        Flagship.sharedInstance.synchronizeModifications { (result) in
           
             expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
