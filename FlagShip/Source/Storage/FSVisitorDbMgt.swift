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
    public init() {
        super.init(.DatabaseVisitor)
    }

    // INSERT/CREATE operation prepared statement
    override func prepareInsertEntryStmt() -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO table_visitors (id, data_visitor) VALUES (?,?)"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &insertEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare insertEntryStmt")
        }
        return r
    }

    // DELETE operation prepared statement
    override func prepareDeleteEntryStmt() -> Int32 {
        guard super.deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_visitors WHERE id = ?"
        // preparing the query
        let r = sqlite3_prepare(db_opaquePointer, sql, -1, &deleteEntryStmt, nil)
        if r != SQLITE_OK {
            print("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }

    // Read hits from database
    public func readVisitorFromDB(_ visitorId: String) -> Data? {
        let queryStatementString = "SELECT * FROM table_visitors WHERE id = '\(visitorId)';"
        if sqlite3_prepare_v2(db_opaquePointer, queryStatementString, -1, &readEntryStmt, nil) == SQLITE_OK {
            if sqlite3_step(readEntryStmt) == SQLITE_ROW {
                // Get the visitorId for visitor
                if let id = sqlite3_column_text(readEntryStmt, 0) { // Clean later
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
}