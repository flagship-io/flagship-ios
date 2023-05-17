//
//  FSVisitorDbMgt.swift
//  Flagship
//
//  Created by Adel Ferguen on 16/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation
import SQLite3

let DATABASE_VISITOR = "visitor_database.db"

class FSVisitorDatabaseMangment {
    // Get the URL to db store file
    private let visitor_db_URL: URL
    // The database pointer.
    private var db: OpaquePointer?
    // we use prepared statements for efficiency and safe guard against sql injection.
    private var insertEntryStmt: OpaquePointer?
    private var readEntryStmt: OpaquePointer?
    private var deleteEntryStmt: OpaquePointer?
    
    public init() {
        do {
            do {
                visitor_db_URL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent(DATABASE_VISITOR)
                print("URL: %s", visitor_db_URL.absoluteString)
            } catch {
                print("Some error occurred. Returning empty path.")
                visitor_db_URL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTables()
        } catch {
            print("Some error occurred. Returning.")
            return
        }
    }
    
    // Command: sqlite3_open(dbURL.path, &db)
    // Open the DB at the given path. If file does not exists, it will create one for you
    func openDB() throws {
        if sqlite3_open(visitor_db_URL.path, &db) != SQLITE_OK { // error mostly because of corrupt database
            print("error opening database")
            throw SqliteError(message: "error opening database \(visitor_db_URL.absoluteString)")
        }
    }
    
    func createTables() throws {
        // create the tables if they dont exist.
        
        // create the table to store the entries.
        // ID | Name | Employee Id | Designation
        let ret = sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS table_visitors(id TEXT PRIMARY KEY, data_visitor TEXT)", nil, nil, nil)
        if ret != SQLITE_OK { // corrupt database.
            print("Error creating db table - table_visitors")
            throw SqliteError(message: "unable to create table_visitors")
        }
    }
    
    // INSERT/CREATE operation prepared statement
    func prepareInsertEntryStmt() -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO table_visitors (id, data_visitor) VALUES (?,?)"
        // preparing the query
        let r = sqlite3_prepare(db, sql, -1, &insertEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    /////////////////////
    /// INSERT HIT //////
    /////////////////////

    // INSERT/CREATE operation prepared statement
    public func insertVisitor(_ id: String, data_content: String) {
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
    func prepareDeleteEntryStmt() -> Int32 {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_visitors WHERE id = ?"
        // preparing the query
        let r = sqlite3_prepare(db, sql, -1, &deleteEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    // Read hits from database
    public func readVisitorData(_ visitorId: String) -> Data? {
        let queryStatementString = "SELECT * FROM table_visitors WHERE id = '\(visitorId)';"
        if sqlite3_prepare_v2(db, queryStatementString, -1, &readEntryStmt, nil) == SQLITE_OK {
            if sqlite3_step(readEntryStmt) == SQLITE_ROW {
                // Get the visitorId for visitor
                if let id = sqlite3_column_text(readEntryStmt, 0) {
                    // Get the data of visitor
                    if let visitor_data_unSafePointer = sqlite3_column_text(readEntryStmt, 1) {
                        // Convert unsafe -> text ->  data
                        return String(cString: visitor_data_unSafePointer).data(using: .utf8)
                    }
                }
            }
            sqlite3_finalize(readEntryStmt)
        }
        return nil
    }
    
    /////////////////////
    /// DELETE HIT //////
    /////////////////////

    public func delete(visitorId: String) {
        // ensure statements are created on first usage if nil
        guard prepareDeleteEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deleteEntryStmt)
        }
        
        // Inserting name in deleteEntryStmt prepared statement
        if sqlite3_bind_text(deleteEntryStmt, 1, (visitorId as NSString).utf8String, -1, nil) != SQLITE_OK {
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
