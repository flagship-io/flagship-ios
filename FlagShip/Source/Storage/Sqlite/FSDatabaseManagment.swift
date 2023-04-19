//
//  FSqlite.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/04/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation
import SQLite3

let DATABASE_HITS = "hits_database.db"

public class FSDatabaseManagment {
    // Get the URL to db store file
    let hit_db_URL: URL
    // The database pointer.
    var db: OpaquePointer?
    // Prepared statement https://www.sqlite.org/c3ref/stmt.html to insert an event into Table.
    // we use prepared statements for efficiency and safe guard against sql injection.
    var insertEntryStmt: OpaquePointer?
    var readEntryStmt: OpaquePointer?
    var updateEntryStmt: OpaquePointer?
    var deleteEntryStmt: OpaquePointer?
    
    public init() {
        do {
            do {
                hit_db_URL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent(DATABASE_HITS)
                print("URL: %s", hit_db_URL.absoluteString)
            } catch {
                // TODO: Just logging the error and returning empty path URL here. Handle the error gracefully after logging
                print("Some error occurred. Returning empty path.")
                hit_db_URL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTables()
        } catch {
            // TODO: Handle the error gracefully after logging
            print("Some error occurred. Returning.")
            return
        }
    }
    
    // Command: sqlite3_open(dbURL.path, &db)
    // Open the DB at the given path. If file does not exists, it will create one for you
    func openDB() throws {
        if sqlite3_open(hit_db_URL.path, &db) != SQLITE_OK { // error mostly because of corrupt database
            print("error opening database")
            //            deleteDB(dbURL: dbURL)
            throw SqliteError(message: "error opening database \(hit_db_URL.absoluteString)")
        }
    }
    
    func createTables() throws {
        // create the tables if they dont exist.
        
        // create the table to store the entries.
        // ID | Name | Employee Id | Designation
        let ret = sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS table_hits(id TEXT PRIMARY KEY, data_hit TEXT)", nil, nil, nil)
        if ret != SQLITE_OK { // corrupt database.
            print("Error creating db table - table_hits")
            throw SqliteError(message: "unable to create table_hits")
        }
    }
    
    // INSERT/CREATE operation prepared statement
    func prepareInsertEntryStmt() -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO table_hits (id, data_hit) VALUES (?,?)"
        // preparing the query
        let r = sqlite3_prepare(db, sql, -1, &insertEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    // INSERT/CREATE operation prepared statement
    public func insertHitMap(_ id: String, hit_content: String) {
        // ensure statements are created on first usage if nil
        guard prepareInsertEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.insertEntryStmt)
        }
        
        //  At some places (esp sqlite3_bind_xxx functions), we typecast String to NSString and then convert to char*,
        // ex: (eventLog as NSString).utf8String. This is a weird bug in swift's sqlite3 bridging. this conversion resolves it.
        
        // Inserting name in insertEntryStmt prepared statement
        if sqlite3_bind_text(insertEntryStmt, 1, (id as NSString).utf8String, -1, nil) != SQLITE_OK {
            print("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        // Inserting employeeID in insertEntryStmt prepared statement
        if sqlite3_bind_text(insertEntryStmt, 2, (hit_content as NSString).utf8String, -1, nil) != SQLITE_OK {
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
    func prepareDeleteEntryStmt() -> Int32 {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_hits WHERE id = ?"
        // preparing the query
        let r = sqlite3_prepare(db, sql, -1, &deleteEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    // "DELETE FROM Records WHERE EmployeeID = ?"
    public func delete(hitId: String) {
        // ensure statements are created on first usage if nil
        guard prepareDeleteEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deleteEntryStmt)
        }
        
        //  At some places (esp sqlite3_bind_xxx functions), we typecast String to NSString and then convert to char*,
        // ex: (eventLog as NSString).utf8String. This is a weird bug in swift's sqlite3 bridging. this conversion resolves it.
        
        // Inserting name in deleteEntryStmt prepared statement
        if sqlite3_bind_text(deleteEntryStmt, 1, (hitId as NSString).utf8String, -1, nil) != SQLITE_OK {
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
