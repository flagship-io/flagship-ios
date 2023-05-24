//
//  FSQLiteWrapper.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

import SQLite3

let VISITOR_DATA_BASE = "visitor_database.db"
let TRACKING_DATA_BASE = "tracking_database.db"

internal enum FSDatabaseType: String {
    case DatabaseTracking = "table_visitors"
    case DatabaseVisitor = "table_tracking"
}

class FSQLiteWrapper {
    // Get the URL to db store file
    let flagship_db_URL: URL
    // The database pointer.
    
    let fs_db_queue = DispatchQueue(label: "com.flagship.db_queue", attributes: .concurrent)

    internal var db_opaquePointer: OpaquePointer? {
        get {
            return fs_db_queue.sync {
                _db_opaquePointer
            }
        }
        set {
            fs_db_queue.async(flags: .barrier) {
                self._db_opaquePointer = newValue
            }
        }
    }
    
    var _db_opaquePointer: OpaquePointer?
    var insertEntryStmt: OpaquePointer?
    var deleteEntryStmt: OpaquePointer?
    var readEntryStmt: OpaquePointer?
    
    public init(_ dataBaseType: FSDatabaseType) {
        do {
            do {
                flagship_db_URL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent((dataBaseType == .DatabaseVisitor) ? VISITOR_DATA_BASE : TRACKING_DATA_BASE)
                print("URL: %s", flagship_db_URL.absoluteString)
            } catch {
                print("Some error occurred. Returning empty path.")
                flagship_db_URL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTables(dataBaseType)
        } catch {
            print("Some error occurred. Returning.")
            return
        }
    }
    
    // Command: sqlite3_open(dbURL.path, &db)
    // Open the DB at the given path. If file does not exists, it will create one for you
    private func openDB() throws {
        if sqlite3_open_v2(flagship_db_URL.path, &db_opaquePointer, SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK { // error mostly because of corrupt database
            print("error opening database")
            throw SqliteError(message: "error opening database \(flagship_db_URL.absoluteString)")
        }
    }
    
    private func createTables(_ dataBaseType: FSDatabaseType) throws {
        // create the tables if they dont exist.
        // create the table to store the entries.
        let sqlRequestString = (dataBaseType == .DatabaseVisitor) ?
            "CREATE TABLE IF NOT EXISTS table_visitors(id TEXT PRIMARY KEY, data_visitor TEXT)" : /// Request to create visitor table
            "CREATE TABLE IF NOT EXISTS table_hits(id TEXT PRIMARY KEY, data_hit TEXT)" /// Request to create hit table
        
        let ret = sqlite3_exec(db_opaquePointer, sqlRequestString, nil, nil, nil)
        if ret != SQLITE_OK { // corrupt database.
            print("Error creating db table - \(dataBaseType)")
            throw SqliteError(message: "unable to create table_visitors")
        }
    }
    
    // INSERT/CREATE operation prepared statement
    internal func prepareInsertEntryStmt() -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO table_hits (id, data_hit) VALUES (?,?)"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &insertEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    /////////////////////
    /// INSERT ENTITY ///
    /////////////////////

    // RECORD
    public func record_data(_ id: String, data_content: String) {
        // ensure statements are created on first usage if nil
        guard prepareInsertEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.insertEntryStmt)
        }
        
        // Inserting Id in insertEntryStmt prepared statement
        if sqlite3_bind_text(insertEntryStmt, 1, (id as NSString).utf8String, -1, nil) != SQLITE_OK {
            print("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        // Inserting Content in insertEntryStmt prepared statement
        if sqlite3_bind_text(insertEntryStmt, 2, (data_content as NSString).utf8String, -1, nil) != SQLITE_OK {
            print("sqlite3_bind_text(insertEntryStmt)")
            return
        }

        // executing the query to insert values
        let r = sqlite3_step(insertEntryStmt)
        if r != SQLITE_DONE {
            print("sqlite3_step(insertEntryStmt) \(r)")
            return
        }
    }
    
    // DELETE operation prepared statement
    internal func prepareDeleteEntryStmt() -> Int32 {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_hits WHERE id = ?"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &deleteEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    public func delete(idItemToDelete: String) {
        // ensure statements are created on first usage if nil
        guard prepareDeleteEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deleteEntryStmt)
        }
        
        // Inserting name in deleteEntryStmt prepared statement
        if sqlite3_bind_text(deleteEntryStmt, 1, (idItemToDelete as NSString).utf8String, -1, nil) != SQLITE_OK {
            print("sqlite3_bind_text(deleteEntryStmt)")
            return
        }
        
        // executing the query to delete row
        let r = sqlite3_step(deleteEntryStmt)
        if r != SQLITE_DONE {
            print("sqlite3_step(deleteEntryStmt) \(r)")
            return
        }
    }
    
    // DELETE operation prepared statement
    internal func prepareDeleteAllStmt() -> Int32 {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_hits"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &deleteEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    public func flushTable() {
        // ensure statements are created on first usage if nil
        guard prepareDeleteAllStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deleteEntryStmt)
        }
        
        // executing the query to delete row
        let r = sqlite3_step(deleteEntryStmt)
        if r != SQLITE_DONE {
            print("sqlite3_step(deleteEntryStmt) \(r)")
            return
        }
    }
    
    // Indicates an exception during a SQLite Operation.
    class SqliteError: Error {
        var message = ""
        var error = SQLITE_ERROR
        init(message: String = "") {
            self.message = message
        }
        
        init(error: Int32) {
            self.error = error
        }
    }
}
