//
//  FSVisitorDbMgt.swift
//  Flagship
//
//  Created by Adel Ferguen on 16/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation
import SQLite3

class FSVisitorDbMgt: FSQLiteWrapper {
    // Add this constant at the class level
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    public init() {
        super.init(.DatabaseVisitor)
    }

    // INSERT/CREATE operation prepared statement
    override func prepareInsertEntryStmt() -> Int32 {
        guard recordPointer == nil else { return SQLITE_OK }
        let sql = "INSERT INTO table_visitors (id, data_visitor) VALUES (?,?)"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &recordPointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 insert error"))
        }
        return r
    }

    // DELETE operation prepared statement
    override func prepareDeleteEntryStmt() -> Int32 {
        guard super.deletePointer == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_visitors WHERE id = ?"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &deletePointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 delete error"))
        }
        return r
    }

    // Read visitor from database
    public func readVisitorFromDB(_ visitorId: String) -> Data? {
        let queryStatementString = "SELECT * FROM table_visitors WHERE id = '\(visitorId)';"
        if sqlite3_prepare_v2(db_opaquePointer, queryStatementString, -1, &readPointer, nil) == SQLITE_OK {
            if sqlite3_step(readPointer) == SQLITE_ROW {
                // Get the visitorId for visitor
                // Get the data of visitor
                if let visitor_data_unSafePointer = sqlite3_column_text(readPointer, 1) {
                    // Convert unsafe -> text ->  data
                    return String(cString: visitor_data_unSafePointer).data(using: .utf8)
                }
            }
            sqlite3_finalize(readPointer)
        }
        return nil
    }
    
    // Add this function to FSVisitorDbMgt class
    public func isVisitorExist(_ visitorId: String) -> Bool {
        var queryPointer: OpaquePointer?
        let queryStatementString = "SELECT COUNT(*) FROM table_visitors WHERE id = ?;"
        
        // Prepare the query with parameter binding for safety
        guard sqlite3_prepare_v2(db_opaquePointer, queryStatementString, -1, &queryPointer, nil) == SQLITE_OK else {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 prepare error"))
            return false
        }
        
        defer {
            // Always cleanup the prepared statement
            sqlite3_finalize(queryPointer)
        }
        
        // Bind the visitor ID parameter (safer than string interpolation)
        guard sqlite3_bind_text(queryPointer, 1, (visitorId as NSString).utf8String, -1, SQLITE_TRANSIENT) == SQLITE_OK else {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 binding error"))
            return false
        }
        
        // Execute the query and get the count
        if sqlite3_step(queryPointer) == SQLITE_ROW {
            let count = sqlite3_column_int(queryPointer, 0)
            return count > 0
        }
        
        return false
    }
}
