//
//  MockURLProtocol.swift
//  FlagshipTests
//
//  Created by Adel on 18/10/2021.
// inspired from https://blog.devgenius.io/unit-test-networking-code-in-swift-without-making-loads-of-mock-classes-74489d0b12a8
//

import Flagship
import UIKit

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        // To check if this protocol can handle the given request.
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        // Here you return the canonical version of the request but most of the time you pass the orignal one.
        return request
    }

    override func startLoading() {
        // This is where you create the mock response as per your test case and send it to the URLProtocolClient.
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }

        do {
            // 2. Call handler with received request and capture the tuple of response and data.
            let (response, data) = try handler(request)

            // 3. Send received response to the client.
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = data {
                // 4. Send received data to the client.
                client?.urlProtocol(self, didLoad: data)
            }

            // 5. Notify request has been finished.
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // 6. Notify received error.
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // This is called if the request gets canceled or completed.
    }
}

class FSTestCacheManager: FSHitCacheDelegate {
    public var isCacheHitsCalled = false
    public var isFlushHitsCalled = false

    func cacheHits(hits: [String: [String: Any]]) {
        isCacheHitsCalled = true
    }

    func lookupHits() -> [String: [String: Any]] {
        return [:]
    }

    func flushHits(hitIds: [String]) {
        isFlushHitsCalled = true
    }

    func flushAllHits() {}
}
