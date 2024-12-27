//
//  FSEmotionTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 24/12/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSEmotionTest: XCTestCase {
    var fsConfig: FlagshipConfig?
    var urlFakeSession: URLSession?
    var listOfData: [Data] = []
    override func setUpWithError() throws {
        super.setUp()
        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)

        let listofFile = ["settings", "score"]
        // ===> [data of ressource, data of score]
        // Load Setting and Score
        do {
            let testBundle = Bundle(for: type(of: self))

            for file in listofFile {
                guard let path = testBundle.url(forResource: file, withExtension: "json") else {
                    return
                }

                try listOfData.append(Data(contentsOf: path, options: .alwaysMapped))
            }
        } catch {
            print("---------------- Failed to load the buckeMock file ----------")
        }
    }

    func testInit() {
        let emotionAi = FSEmotionAI(visitorId: "userAi", usingSwizzling: true)

        XCTAssertTrue(emotionAi.swizzlingEnabled)
        XCTAssertEqual(emotionAi.visitorId, "userAi")
    }

    func testStartEAICollectForView() {
        let expectationSync = XCTestExpectation(description: "start Collection")

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "---")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        let emotionAi = FSEmotionAI(visitorId: "userAi", usingSwizzling: true)
        emotionAi.service?.serviceSession = urlFakeSession ?? URLSession(configuration: URLSessionConfiguration.ephemeral)
        let windo = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        emotionAi.startEAICollectForView(windo, nameScreen: "testScreen") { ret in

            if ret {
                XCTAssertTrue(emotionAi.status == .PROGRESS)
                XCTAssertTrue(emotionAi.currentScreenName == "testScreen")
                XCTAssertTrue(emotionAi.panGesture?.delegate != nil)

                for _ in 0 ..< 15 {
                    Thread.sleep(forTimeInterval: 1)
                    let panGesture = UIPanGestureRecognizer()
                    panGesture.setTranslation(CGPoint(x: 100, y: 100), in: windo)
                    panGesture.state = .ended
 
                    if emotionAi.panGesture?.isEnabled ?? false {
                        emotionAi.handlePan(panGesture)
                    } else {
                        XCTAssertTrue(emotionAi.status == .STOPED)
                    }
                }

                expectationSync.fulfill()
            }
        }
    }
}
