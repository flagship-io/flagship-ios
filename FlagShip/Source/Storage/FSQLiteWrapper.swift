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
    var flagship_db_URL: URL
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
    var recordPointer: OpaquePointer?
    var deletePointer: OpaquePointer?
    var readPointer: OpaquePointer?
    
    public init(_ dataBaseType: FSDatabaseType) {
        if let rootPath = FSQLiteWrapper.createUrlForDatabaseCache() {
            flagship_db_URL = rootPath.appendingPathComponent((dataBaseType == .DatabaseVisitor) ? VISITOR_DATA_BASE : TRACKING_DATA_BASE)
            //print("URL: %s", flagship_db_URL.absoluteString)
            
            do { try openDB() } catch { print(" Error when opening database") }
            do { try createTables(dataBaseType) } catch { print(" Error on creating table") }
            
        } else {
            flagship_db_URL = URL(fileURLWithPath: "")
            print("Some error occurred. Returning.")
            return
        }
    }
    
    // Open the DB at the given path. If file does not exists, it will create one for you
    private func openDB() throws {
        if sqlite3_open_v2(flagship_db_URL.path, &db_opaquePointer, SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK {
            throw FlagshipError(message: "Error when opening database \(flagship_db_URL.absoluteString)")
        }
    }
    
    private func createTables(_ dataBaseType: FSDatabaseType) throws {
        // create the tables
        let sqlRequestString = (dataBaseType == .DatabaseVisitor) ?
            "CREATE TABLE IF NOT EXISTS table_visitors(id TEXT PRIMARY KEY, data_visitor TEXT)" : /// Request to create visitor table
            "CREATE TABLE IF NOT EXISTS table_hits(id TEXT PRIMARY KEY, data_hit TEXT)" /// Request to create hit table
        
        let ret = sqlite3_exec(db_opaquePointer, sqlRequestString, nil, nil, nil)
        if ret != SQLITE_OK {
            print("Error on creating db table - \(dataBaseType)")
            throw FlagshipError(message: "Error on creating table_visitors")
        }
    }
    
    // INSERT/CREATE operation prepared statement
    internal func prepareInsertEntryStmt() -> Int32 {
        guard recordPointer == nil else { return SQLITE_OK }
        let sql = "INSERT INTO table_hits (id, data_hit) VALUES (?,?)"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &recordPointer, nil)
        if r != SQLITE_OK {
            //print("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    /////////////////////
    /// INSERT        ///
    /////////////////////

    // RECORD
    public func record_data(_ id: String, data_content: String) {
        // ensure statements are created on first usage if nil
        guard prepareInsertEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.recordPointer)
        }
        
        // Inserting Id in insertEntryStmt prepared statement
        if sqlite3_bind_text(recordPointer, 1, (id as NSString).utf8String, -1, nil) != SQLITE_OK {
            print("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        // Inserting Content in insertEntryStmt prepared statement
        if sqlite3_bind_text(recordPointer, 2, (data_content as NSString).utf8String, -1, nil) != SQLITE_OK {
            print("sqlite3_bind_text(insertEntryStmt)")
            return
        }

        // executing the query to insert values
        let r = sqlite3_step(recordPointer)
        if r != SQLITE_DONE {
            print("sqlite3_step(insertEntryStmt) \(r)")
            return
        }
    }
    
    // DELETE operation prepared statement
    internal func prepareDeleteEntryStmt() -> Int32 {
        guard deletePointer == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_hits WHERE id = ?"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &deletePointer, nil)
        if r != SQLITE_OK {
            // print("sqlite3_prepare deleteEntryStmt")
        }
        
        return r
    }
    
    public func delete(idItemToDelete: String) {
        // ensure statements are created on first usage if nil
        guard prepareDeleteEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deletePointer)
        }
        
        // Inserting name in deleteEntryStmt prepared statement
        if sqlite3_bind_text(deletePointer, 1, (idItemToDelete as NSString).utf8String, -1, nil) != SQLITE_OK {
            // print("sqlite3_bind_text(deleteEntryStmt)")
            return
        }
        
        // executing the query to delete row
        let r = sqlite3_step(deletePointer)
        if r != SQLITE_DONE {
            // print("sqlite3_step(deleteEntryStmt) \(r)")
            return
        }
    }
    
    // DELETE operation prepared statement
    internal func prepareDeleteAllStmt() -> Int32 {
        guard deletePointer == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_hits"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &deletePointer, nil)
        if r != SQLITE_OK {
            // print("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    public func flushTable() {
        // ensure statements are created on first usage if nil
        guard prepareDeleteAllStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deletePointer)
        }
        
        // executing the query to delete row
        let r = sqlite3_step(deletePointer)
        if r != SQLITE_DONE {
            // print("sqlite3_step(deleteEntryStmt) \(r)")
            return
        }
    }
    
    class func createUrlForDatabaseCache() -> URL? {
        do {
            var url = try FileManager.default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            // Append Flagship directory
            url.appendPathComponent("Flagship", isDirectory: true)
            // Check if exist
            if FileManager.default.fileExists(atPath: url.path) == false {
                // Create directory
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                    return url
                    
                } catch {
                    FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Failed to create directory Flagship for database"))
                    return nil
                }
            } else {
                return url
            }
            
        } catch {
            print("Error on create url for database")
            return nil
        }
    }
}
