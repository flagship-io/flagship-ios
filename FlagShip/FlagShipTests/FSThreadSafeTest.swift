//
//  FSThreadSafeTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 09/03/2026.
//  Copyright © 2026 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

class FSThreadSafeTest: XCTestCase {

    override func setUpWithError() throws {
        // Reset le singleton avant chaque test pour éviter la pollution d'état
        Flagship.sharedInstance.reset()
        // Attendre que le barrier async soit terminé
        Flagship.sharedInstance.fsQueue.sync(flags: .barrier) {}
    }

    override func tearDownWithError() throws {
        Flagship.sharedInstance.reset()
        Flagship.sharedInstance.fsQueue.sync(flags: .barrier) {}
    }

    // MARK: - sharedInstance accédé depuis un background thread

    /// Un background thread accède à sharedInstance
    /// avant que main thread ait eu le temps d'init le singleton
    func testSharedInstanceAccessFromBackgroundThread() {
        let expectation = self.expectation(description: "sharedInstance accessible depuis background thread sans crash")

        DispatchQueue.global(qos: .background).async {
            let instance = Flagship.sharedInstance
            XCTAssertNotNil(instance, "sharedInstance ne doit pas être nil depuis un background thread")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - start() appelé depuis un background thread
    func testStartFromBackgroundThread() {
        let expectation = self.expectation(description: "start() depuis background thread sans crash")

        DispatchQueue.global(qos: .default).async {
            // Ne doit PAS crasher même si appelé depuis un thread background
            Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")
            XCTAssertEqual(Flagship.sharedInstance.currentStatus, .SDK_INITIALIZED)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - Accès concurrent depuis plusieurs threads simultanés

    /// Simule plusieurs queues (background threads, main thread, URLSession queue...)
    /// accédant toutes à sharedInstance en même temps — race condition classique
    func testConcurrentSharedInstanceAccess() {
        let count = 20
        let expectation = self.expectation(description: "Accès concurrent sharedInstance")
        expectation.expectedFulfillmentCount = count

        for i in 0..<count {
            let qos: DispatchQoS.QoSClass = i % 2 == 0 ? .background : .userInitiated
            DispatchQueue.global(qos: qos).async {
                let instance = Flagship.sharedInstance
                XCTAssertNotNil(instance)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10)
    }

 

    // MARK: - start() sans config utilise currentConfig (pas de double build)

    func testStartWithoutConfigUsesCurrentConfig() {
        // On démarre sans fournir de config → doit utiliser FSConfigBuilder().build() par défaut
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")
        XCTAssertNotNil(Flagship.sharedInstance.currentConfig, "currentConfig ne doit pas être nil après start()")
        XCTAssertEqual(Flagship.sharedInstance.currentConfig?.mode, .DECISION_API, "mode par défaut doit être DECISION_API")
        XCTAssertEqual(Flagship.sharedInstance.currentStatus, .SDK_INITIALIZED)
    }

    // MARK: - SQLiteWrapper — record concurrent (race condition sur _recordPointer)
    func testSQLiteWrapperConcurrentRecord() {
        let db = FSQLiteWrapper(.DatabaseTracking)
        let count = 50
        let group = DispatchGroup()

        for i in 0..<count {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                db.record_data("hit_\(i)", data_content: "{\"id\":\"\(i)\"}")
                group.leave()
            }
        }

        // Attendre que tous les dispatches externes soient lancés
        group.wait()
        // Puis attendre que toutes les opérations SQLite internes soient terminées
        db.waitForPendingOperations()
        // Si on arrive ici sans crash, le test est OK
        XCTAssertTrue(true, "50 record_data() concurrents sans crash")
    }

    // MARK: -  SQLiteWrapper — delete et flushTable en parallèle
    func testSQLiteWrapperConcurrentDeleteAndFlush() {
        let db = FSQLiteWrapper(.DatabaseTracking)
        let group = DispatchGroup()

        // Insérer quelques entrées d'abord et attendre la fin
        for i in 0..<10 {
            db.record_data("hit_\(i)", data_content: "{\"id\":\"\(i)\"}")
        }
        db.waitForPendingOperations()

        // Appeler delete et flush simultanément — ne doit pas crasher
        group.enter()
        DispatchQueue.global(qos: .background).async {
            db.delete(idItemToDelete: "hit_1")
            group.leave()
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            db.flushTable()
            group.leave()
        }

        group.wait()
        db.waitForPendingOperations()
        XCTAssertTrue(true, "delete() + flushTable() simultanés sans crash")
    }

    // MARK: - SQLiteWrapper — toutes opérations en stress test

    /// Simule un scénario réel : enregistrements, suppressions et flush simultanés
    /// comme peuvent le faire le tracking queue et d'autres queues en parallèle
    func testSQLiteWrapperStressTest() {
        let db = FSQLiteWrapper(.DatabaseTracking)
        let count = 30
        let group = DispatchGroup()

        for i in 0..<count {
            group.enter()
            DispatchQueue.global(qos: .background).async {
                db.record_data("stress_\(i)", data_content: "{\"value\":\"\(i)\"}")
                group.leave()
            }
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                db.delete(idItemToDelete: "stress_\(i)")
                group.leave()
            }
            group.enter()
            DispatchQueue.global(qos: .default).async {
                db.flushTable()
                group.leave()
            }
        }

        group.wait()
        db.waitForPendingOperations()
        XCTAssertTrue(true, "stress test \(count * 3) opérations concurrentes sans crash")
    }

    // MARK: - FSQLiteWrapper init depuis background thread
     /// appelé depuis un background thread
    func testSQLiteWrapperInitFromBackgroundThread() {
        let expectation = self.expectation(description: "FSQLiteWrapper init depuis background thread sans crash")

        DispatchQueue.global(qos: .background).async {
             let db = FSQLiteWrapper(.DatabaseTracking)
            XCTAssertNotNil(db, "FSQLiteWrapper ne doit pas être nil")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // MARK: - FSConfigBuilder init depuis background thread
    func testFSConfigBuilderInitFromBackgroundThread() {
        let expectation = self.expectation(description: "FSConfigBuilder init depuis background thread sans crash")

        DispatchQueue.global(qos: .background).async {
            let config = FSConfigBuilder().build()
            XCTAssertNotNil(config)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
