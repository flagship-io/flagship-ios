//
//  QAReportTest.swift
//  FlagshipTests
//
//  Created by Adel on 29/03/2022.
//

import XCTest
@testable import Flagship

class QAReportTest: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23")
    }
    
    ///_ For more information about scenario see the: https://docs.google.com/spreadsheets/d/1-msKD3O1jssiC7nLdDfEtIhdRJh9_hIvDVOSdzDb04M/edit#gid=1574309067
    func testReportQA_1(){
        /// _ list of users
        let listUsers = ["visitor_a", "visitor_B_B", "visitor_0_0","zZz_visitor_zZz" ]
        
        for userId in listUsers {
            
            let expectationSync = XCTestExpectation(description: "testReportQA_1")
            let v2 = Flagship.sharedInstance.newVisitor( userId).withContext(context: ["qa_report" : true]).build()
            
            v2.fetchFlags {
                
                if Flagship.sharedInstance.getStatus() == .READY {
                    
                    let flag = v2.getFlag(key: "qa_report_var", defaultValue: "default")
                    
                    print(" The flag value for \(userId) is =   \(flag.value(userExposed: false) ?? "Flag is nil")")
                    
                    if flag.exists(){
                        
                        /// Expose key
                        if userId != "visitor_0_0"{
                            flag.userExposed()
                        }
                       
                        /// Send Screen Hit
                        if userId != "visitor_B_B"{
                            
                            v2.sendHit(FSScreen("I LOVE QA"))
                        }
                       
                    }
                }
                expectationSync.fulfill()
            }
            wait(for: [expectationSync], timeout: 5.0)
            
        }
    }
    
    
    //Create a new visitor "visitor_1111"
//    update context : "qa_report":true
//    Fetch falgs (or synchronize)
//    get the flag "qa_report_var" (or getModification)
//    expose user to flag "qa_report_var" (or activate)
//    Set consent to false
//    Send a screenview hit "I LOVE QA"
    func testReportQA_2(){
        
        let userId = "visitor_1111"
        
        let expectationSync = XCTestExpectation(description: "testReportQA_2")
        let v2 = Flagship.sharedInstance.newVisitor( userId).withContext(context: ["qa_report" : true]).build()
        
        v2.fetchFlags {
            
            if Flagship.sharedInstance.getStatus() == .READY {
                
                let flag = v2.getFlag(key: "qa_report_var", defaultValue: "default")
                
                print(" The flag value for \(userId) is =   \(flag.value(userExposed: false) ?? "Flag is nil")")
                
                if flag.exists(){
                    
                    flag.userExposed()
                    /// Send Screen Hit
                    v2.setConsent(hasConsented: false)
                    v2.sendHit(FSScreen("I LOVE QA"))
                }
            }
            expectationSync.fulfill()
        }
        wait(for: [expectationSync], timeout: 5.0)
    }
    
    
//    Create a new visitor "visitor_22"
//    update context : "qa_report":false
//    Set consent to true
//    Fetch falgs (or synchronize)
//    get the flag "qa_report_var" (or getModification)
//    expose user to flag "qa_report_var" (or activate)
//    Send a screenview hit "I LOVE QA"
    func testReportQA_3(){
        
        let userId = "visitor_22"
        
        let expectationSync = XCTestExpectation(description: "testReportQA_3")
        let v2 = Flagship.sharedInstance.newVisitor( userId).withContext(context: ["qa_report" : false]).build()
        
        v2.fetchFlags {
            
            if Flagship.sharedInstance.getStatus() == .READY {
                let flag = v2.getFlag(key: "qa_report_var", defaultValue: "default")
                print(" The flag value for \(userId) is =   \(flag.value(userExposed: false) ?? "Flag is nil")")
                flag.userExposed()
                v2.sendHit(FSScreen("I LOVE QA"))
            }
            expectationSync.fulfill()
        }
        wait(for: [expectationSync], timeout: 5.0)
    }
    
// this test is to run under panic mode
//    Create a new visitor "visitor_333"
//    update context : "qa_report":true
//    Fetch falgs (or synchronize)
//    get the flag "qa_report_var" (or getModification)
//    expose user to flag "qa_report_var" (or activate)
//    Send a screenview hit "I LOVE QA"
    
    func testReportQA_6(){
        
        let userId = "visitor_333"
        
        let expectationSync = XCTestExpectation(description: "testReportQA_6")
        let v2 = Flagship.sharedInstance.newVisitor( userId).withContext(context: ["qa_report" : true]).build()
        
        v2.fetchFlags {
            
            if Flagship.sharedInstance.getStatus() == .PANIC_ON {
                
                let flag = v2.getFlag(key: "qa_report_var", defaultValue: "default")
                
                print(" The flag value for \(userId) is =   \(flag.value(userExposed: false) ?? "Flag is nil")")
                flag.userExposed()
                v2.sendHit(FSScreen("I LOVE QA"))
            }
            expectationSync.fulfill()
        }
        wait(for: [expectationSync], timeout: 5.0)
    }
    
    func testReportXpc_1(){
        
        let expectationSync = XCTestExpectation(description: "testReportXpc_1")
        let anonymUser = Flagship.sharedInstance.newVisitor("anonymous1").withContext(context: ["qa_report_xpc" : true]).build()
        
        anonymUser.fetchFlags {
            
            print("################ INIT ANONYMOUS USER ####################")
            if Flagship.sharedInstance.getStatus() == .READY{
                
                let flag = anonymUser.getFlag(key: "qa_report_xpc", defaultValue: "default")
                
                if flag.exists() {
                    
                    /// _Read value & _Activate
                    print(" ----------- The Flag for \(anonymUser.visitorId) is \(flag.value())-------------")
                }
                
                /// _ authenticate
                print("################ FROM ANONYMOUS USER ===> LOGGED USER ####################")
                anonymUser.authenticate(visitorId: "logged_1")
                anonymUser.fetchFlags {
                    
                    let flag = anonymUser.getFlag(key: "qa_report_xpc", defaultValue: "default")
                    
                    if flag.exists() {
                        
                        /// _Read value & _Activate
                        print(" ----------- The Flag for \(anonymUser.visitorId) is \(flag.value())-------------")
                    }
                    
                    /// Send the screen hit
                    anonymUser.sendHit(FSScreen("I DONT LOVE QA XPC"))
                    
                    
                    /// Unauthenticate
                    print("################ LOGGED USER ===> FROM ANONYMOUS USER ####################")
                    anonymUser.unauthenticate()
                    anonymUser.fetchFlags {

                        let flag = anonymUser.getFlag(key: "qa_report_xpc", defaultValue: "default")

                        if flag.exists() {

                            /// _Read value & _Activate
                            print(" ----------- The Flag for \(anonymUser.visitorId) is \(flag.value())-------------")
                        }

                        /// Send the screen hit
                        anonymUser.sendHit(FSScreen("I DONT LOVE QA XPC"))
                        expectationSync.fulfill()

                    }
                }
            }
        }
        wait(for: [expectationSync], timeout: 10.0)
        
    }
    
    
    
    func testReportXpc_2(){
        
        let expectationSync = XCTestExpectation(description: "testReportXpc_2")
        let anonymUser = Flagship.sharedInstance.newVisitor("ano1").withContext(context: ["qa_report_xpc2" : true]).build()
        
        anonymUser.fetchFlags {
            
            print("################ INIT ANONYMOUS USER ####################")
            if Flagship.sharedInstance.getStatus() == .READY{
                
                let flag = anonymUser.getFlag(key: "qa_report_xpc2", defaultValue: "default")
                
                if flag.exists() {
                    
                    /// _Read value & _Activate
                    print(" ----------- The Flag for \(anonymUser.visitorId) is \(flag.value())-------------")
                }
                
                /// _ authenticate
                print("################ FROM ANONYMOUS USER ===> LOGGED USER ####################")
                anonymUser.authenticate(visitorId: "log1")
                anonymUser.fetchFlags {
                    
                    let flag = anonymUser.getFlag(key: "qa_report_xpc2", defaultValue: "default")
                    
                    if flag.exists() {
                        
                        /// _Read value & _Activate
                        print(" ----------- The Flag for \(anonymUser.visitorId) is \(flag.value())-------------")
                    }
                    
                    /// Send the screen hit
                    anonymUser.sendHit(FSScreen("WTF QA XPC 2"))
                    
                    
                    ///_ Create ano2
                    let ano2 = Flagship.sharedInstance.newVisitor("ano2").withContext(context:["qa_report_xpc2":true]).build()
                    ano2.fetchFlags {
                        let flag = anonymUser.getFlag(key: "qa_report_xpc2", defaultValue: "default")
                        if flag.exists() {
                            
                            /// _Read value & _Activate
                            print(" ----------- The Flag for \(ano2.visitorId) is \(flag.value())-------------")
                        }
                        
                        /// _ Authenticate visitor with "log1"
                        ano2.authenticate(visitorId: "log1")
                        ano2.fetchFlags {
                            
                            let flag = ano2.getFlag(key: "qa_report_xpc2", defaultValue: "default")
                            if flag.exists() {
                                
                                /// _ Read value & _Activate
                                print(" ----------- The Flag for \(ano2.visitorId) is \(flag.value())-------------")
                            }
                            /// _ Send screen hit
                            ano2.sendHit(FSScreen("WTF QA XPC 2"))
                            
                            /// _ Create ano3
                            let ano3 = Flagship.sharedInstance.newVisitor("ano3").withContext(context:["qa_report_xpc2":true]).build()
                            ano3.fetchFlags {
                                
                                let flag = ano3.getFlag(key: "qa_report_xpc2", defaultValue: "default")
                                if flag.exists() {
                                    
                                    /// _ Read value & _Activate
                                    print(" ----------- The Flag for \(ano3.visitorId) is \(flag.value())-------------")
                                }
                                /// Send hit
                                ano3.sendHit(FSScreen("WTF QA XPC 2"))
                                
                                /// _ Authenticate visitor with "log1"
                                ano3.authenticate(visitorId: "log1")
                                
                                ano3.fetchFlags {
                                    let flag = ano3.getFlag(key: "qa_report_xpc2", defaultValue: "default")
                                    if flag.exists() {
                                        
                                        /// _ Read value & _Activate
                                        print(" ----------- The Flag for \(ano3.visitorId) is \(flag.value())-------------")
                                    }
                                    /// Send hit
                                    ano3.sendHit(FSScreen("WTF QA XPC 2"))
                                    
                                    expectationSync.fulfill()

                                }
                                
                            }
                        }

                    }
                    
                }
            }
          
        }
        wait(for: [expectationSync], timeout: 5.0)
        
    }
    
    
    
}
