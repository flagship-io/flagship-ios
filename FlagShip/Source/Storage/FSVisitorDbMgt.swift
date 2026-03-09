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

    // Statements propres à la table table_visitors
    // Protégés par fs_db_queue héritée — jamais accédés hors de la queue
    private var _visitorRecordPointer: OpaquePointer?
    private var _visitorDeletePointer: OpaquePointer?
    private var _visitorReadPointer: OpaquePointer?

    public init() {
        super.init(.DatabaseVisitor)
    }

    // MARK: - Prepared statements (appelés UNIQUEMENT depuis fs_db_queue)

    private func prepareInsertStmtIfNeeded() -> Int32 {
        guard _visitorRecordPointer == nil else { return SQLITE_OK }
        let sql = "INSERT OR REPLACE INTO table_visitors (id, data_visitor) VALUES (?,?)"
        let r = sqlite3_prepare_v2(_db_opaquePointer, sql, -1, &_visitorRecordPointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 visitor insert prepare error"))
        }
        return r
    }

    private func prepareDeleteStmtIfNeeded() -> Int32 {
        guard _visitorDeletePointer == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_visitors WHERE id = ?"
        let r = sqlite3_prepare_v2(_db_opaquePointer, sql, -1, &_visitorDeletePointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 visitor delete prepare error"))
        }
        return r
    }

    // MARK: - Public API (thread-safe via fs_db_queue héritée)

    override public func record_data(_ id: String, data_content: String) {
        fs_db_queue.async { [weak self] in
            guard let self else { return }
            guard self.prepareInsertStmtIfNeeded() == SQLITE_OK else { return }
            defer { sqlite3_reset(self._visitorRecordPointer) }

            if sqlite3_bind_text(self._visitorRecordPointer, 1, (id as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 visitor bind id error"))
                return
            }
            if sqlite3_bind_text(self._visitorRecordPointer, 2, (data_content as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 visitor bind data error"))
                return
            }
            if sqlite3_step(self._visitorRecordPointer) != SQLITE_DONE {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 visitor step insert error"))
            }
        }
    }

    override public func delete(idItemToDelete: String) {
        fs_db_queue.async { [weak self] in
            guard let self else { return }
            guard self.prepareDeleteStmtIfNeeded() == SQLITE_OK else { return }
            defer { sqlite3_reset(self._visitorDeletePointer) }

            if sqlite3_bind_text(self._visitorDeletePointer, 1, (idItemToDelete as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 visitor bind delete id error"))
                return
            }
            if sqlite3_step(self._visitorDeletePointer) != SQLITE_DONE {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 visitor step delete error"))
            }
        }
    }

    // MARK: - Read (synchrone — retourne le résultat immédiatement via fs_db_queue.sync)

    public func readVisitorFromDB(_ visitorId: String) -> Data? {
        var result: Data?
        fs_db_queue.sync { [weak self] in
            guard let self else { return }
            let sql = "SELECT id, data_visitor FROM table_visitors WHERE id = ?;"
            guard sqlite3_prepare_v2(self._db_opaquePointer, sql, -1, &self._visitorReadPointer, nil) == SQLITE_OK else { return }
            defer { sqlite3_finalize(self._visitorReadPointer); self._visitorReadPointer = nil }

            sqlite3_bind_text(self._visitorReadPointer, 1, (visitorId as NSString).utf8String, -1, nil)

            if sqlite3_step(self._visitorReadPointer) == SQLITE_ROW,
               let ptr = sqlite3_column_text(self._visitorReadPointer, 1) {
                result = String(cString: ptr).data(using: .utf8)
            }
        }
        return result
    }

    // MARK: - Deinit

    deinit {
        fs_db_queue.sync {
            sqlite3_finalize(_visitorRecordPointer)
            sqlite3_finalize(_visitorDeletePointer)
            sqlite3_finalize(_visitorReadPointer)
        }
    }
}
