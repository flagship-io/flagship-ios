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
}
