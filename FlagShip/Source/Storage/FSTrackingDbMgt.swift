//
//  FSTrackingDbMgt.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation
import SQLite3

class FSTrackingDbMgt: FSQLiteWrapper {

    // Statements propres à la table table_hits
    // Protégés par fs_db_queue héritée — jamais accédés hors de la queue
    private var _trackingRecordPointer: OpaquePointer?
    private var _trackingDeletePointer: OpaquePointer?
    private var _trackingReadPointer: OpaquePointer?

    public init() {
        super.init(.DatabaseTracking)
    }

    // MARK: - Prepared statements (appelés UNIQUEMENT depuis fs_db_queue)

    private func prepareInsertStmtIfNeeded() -> Int32 {
        guard _trackingRecordPointer == nil else { return SQLITE_OK }
        let sql = "INSERT OR REPLACE INTO table_hits (id, data_hit) VALUES (?,?)"
        let r = sqlite3_prepare_v2(_db_opaquePointer, sql, -1, &_trackingRecordPointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 insert error"))
        }
        return r
    }

    private func prepareDeleteStmtIfNeeded() -> Int32 {
        guard _trackingDeletePointer == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_hits WHERE id = ?"
        let r = sqlite3_prepare_v2(_db_opaquePointer, sql, -1, &_trackingDeletePointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 delete error"))
        }
        return r
    }

    // MARK: - Public API (thread-safe via fs_db_queue héritée)

    override public func record_data(_ id: String, data_content: String) {
        fs_db_queue.async { [weak self] in
            guard let self else { return }
            guard self.prepareInsertStmtIfNeeded() == SQLITE_OK else { return }
            defer { sqlite3_reset(self._trackingRecordPointer) }

            if sqlite3_bind_text(self._trackingRecordPointer, 1, (id as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 tracking bind id error"))
                return
            }
            if sqlite3_bind_text(self._trackingRecordPointer, 2, (data_content as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 tracking bind data error"))
                return
            }
            if sqlite3_step(self._trackingRecordPointer) != SQLITE_DONE {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 tracking step insert error"))
            }
        }
    }

    override public func delete(idItemToDelete: String) {
        fs_db_queue.async { [weak self] in
            guard let self else { return }
            guard self.prepareDeleteStmtIfNeeded() == SQLITE_OK else { return }
            defer { sqlite3_reset(self._trackingDeletePointer) }

            if sqlite3_bind_text(self._trackingDeletePointer, 1, (idItemToDelete as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 tracking bind delete id error"))
                return
            }
            if sqlite3_step(self._trackingDeletePointer) != SQLITE_DONE {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("sqlite3 tracking step delete error"))
            }
        }
    }

    // MARK: - Read (synchrone — retourne le résultat via fs_db_queue.sync)

    public func readTrackingFromDB() -> [String: [String: Any]] {
        var result: [String: [String: Any]] = [:]
        fs_db_queue.sync { [weak self] in
            guard let self else { return }
            let sql = "SELECT * FROM table_hits;"
            guard sqlite3_prepare_v2(self._db_opaquePointer, sql, -1, &self._trackingReadPointer, nil) == SQLITE_OK else { return }
            defer { sqlite3_finalize(self._trackingReadPointer); self._trackingReadPointer = nil }

            while sqlite3_step(self._trackingReadPointer) == SQLITE_ROW {
                guard let idPtr = sqlite3_column_text(self._trackingReadPointer, 0),
                      let dataPtr = sqlite3_column_text(self._trackingReadPointer, 1) else { continue }

                let id = String(cString: idPtr)
                if let data = String(cString: dataPtr).data(using: .utf8),
                   let dico = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    result[id] = dico
                } else {
                    FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Error on decode dataRawColl"))
                }
            }
        }
        return result
    }

    // MARK: - Deinit

    deinit {
        fs_db_queue.sync {
            sqlite3_finalize(_trackingRecordPointer)
            sqlite3_finalize(_trackingDeletePointer)
            sqlite3_finalize(_trackingReadPointer)
        }
    }
}
