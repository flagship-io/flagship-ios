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

enum FSDatabaseType: String {
    case DatabaseTracking = "table_visitors"
    case DatabaseVisitor = "table_tracking"
}

class FSQLiteWrapper {
    // Get the URL to db store file
    var flagship_db_URL: URL
    
    // The database pointer — accessible aux sous-classes via la queue
    var _db_opaquePointer: OpaquePointer?
    
    // Prepared statements — chacun a son propre pointeur pour éviter tout conflit
    private var _recordPointer: OpaquePointer?
    private var _deletePointer: OpaquePointer?
    private var _deleteAllPointer: OpaquePointer? // séparé de _deletePointer
    private var _readPointer: OpaquePointer?
    
    // Serial queue : accessible aux sous-classes pour protéger leurs propres statements
    let fs_db_queue = DispatchQueue(label: "com.flagship.db_queue")
    
    public init(_ dataBaseType: FSDatabaseType) {
        if let rootPath = FSQLiteWrapper.createUrlForDatabaseCache() {
            flagship_db_URL = rootPath.appendingPathComponent((dataBaseType == .DatabaseVisitor) ? VISITOR_DATA_BASE : TRACKING_DATA_BASE)
            do { try openDB() } catch {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Error when opening database"))
            }
            do { try createTables(dataBaseType) } catch {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Error on creating table"))
            }
        } else {
            flagship_db_URL = URL(fileURLWithPath: "")
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error occurred on init database"))
            return
        }
    }
    
    // Open the DB at the given path. If file does not exists, it will create one for you
    private func openDB() throws {
        if sqlite3_open_v2(flagship_db_URL.path, &_db_opaquePointer, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK {
            throw FlagshipError(message: "Error when opening database \(flagship_db_URL.absoluteString)")
        }
    }
    
    private func createTables(_ dataBaseType: FSDatabaseType) throws {
        let sqlRequestString = (dataBaseType == .DatabaseVisitor) ?
            "CREATE TABLE IF NOT EXISTS table_visitors(id TEXT PRIMARY KEY, data_visitor TEXT)" :
            "CREATE TABLE IF NOT EXISTS table_hits(id TEXT PRIMARY KEY, data_hit TEXT)"
        
        if sqlite3_exec(_db_opaquePointer, sqlRequestString, nil, nil, nil) != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error occurred on create database"))
            throw FlagshipError(message: "Error on creating table_visitors")
        }
    }
    
    // MARK: - Prepared statements (appelés UNIQUEMENT depuis fs_db_queue)
    
    /// Prépare INSERT OR REPLACE une seule fois
    private func prepareInsertStmtIfNeeded() -> Int32 {
        guard _recordPointer == nil else { return SQLITE_OK }
        let sql = "INSERT OR REPLACE INTO table_hits (id, data_hit) VALUES (?,?)"
        let r = sqlite3_prepare_v2(_db_opaquePointer, sql, -1, &_recordPointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error on sqlite insert prepare"))
        }
        return r
    }
    
    /// Prépare DELETE by id une seule fois
    private func prepareDeleteStmtIfNeeded() -> Int32 {
        guard _deletePointer == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_hits WHERE id = ?"
        let r = sqlite3_prepare_v2(_db_opaquePointer, sql, -1, &_deletePointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error sqlite delete prepare"))
        }
        return r
    }
    
    /// Prépare DELETE ALL — statement DISTINCT de _deletePointer
    private func prepareDeleteAllStmtIfNeeded() -> Int32 {
        guard _deleteAllPointer == nil else { return SQLITE_OK }
        let sql = "DELETE FROM table_hits"
        let r = sqlite3_prepare_v2(_db_opaquePointer, sql, -1, &_deleteAllPointer, nil)
        if r != SQLITE_OK {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error sqlite deleteAll prepare"))
        }
        return r
    }
    
    // MARK: - Public API (thread-safe via fs_db_queue)
    
    /////////////////////
    /// INSERT        ///
    /////////////////////
    
    public func record_data(_ id: String, data_content: String) {
        fs_db_queue.async { [weak self] in
            guard let self else { return }
            guard self.prepareInsertStmtIfNeeded() == SQLITE_OK else { return }
            defer { sqlite3_reset(self._recordPointer) }
            
            if sqlite3_bind_text(self._recordPointer, 1, (id as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error occurred on record Id"))
                return
            }
            if sqlite3_bind_text(self._recordPointer, 2, (data_content as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error occurred on data content"))
                return
            }
            if sqlite3_step(self._recordPointer) != SQLITE_DONE {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error on step record"))
            }
        }
    }
    
    /////////////////////
    /// DELETE        ///
    /////////////////////
    
    public func delete(idItemToDelete: String) {
        fs_db_queue.async { [weak self] in
            guard let self else { return }
            guard self.prepareDeleteStmtIfNeeded() == SQLITE_OK else { return }
            defer { sqlite3_reset(self._deletePointer) }
            
            if sqlite3_bind_text(self._deletePointer, 1, (idItemToDelete as NSString).utf8String, -1, nil) != SQLITE_OK {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error sqlite on delete"))
                return
            }
            if sqlite3_step(self._deletePointer) != SQLITE_DONE {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error on step delete"))
            }
        }
    }
    
    /////////////////////
    /// FLUSH         ///
    /////////////////////
    
    public func flushTable() {
        fs_db_queue.async { [weak self] in
            guard let self else { return }
            guard self.prepareDeleteAllStmtIfNeeded() == SQLITE_OK else { return }
            defer { sqlite3_reset(self._deleteAllPointer) }
            
            if sqlite3_step(self._deleteAllPointer) != SQLITE_DONE {
                FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Some error on step flushTable"))
            }
        }
    }
    
    // MARK: - Test helper : attend que toutes les opérations async en cours soient terminées
    
    /// Utilisé uniquement dans les tests unitaires pour synchroniser après un record/delete/flush async
    func waitForPendingOperations() {
        fs_db_queue.sync { }
    }
    
    // MARK: - Deinit (évite les leaks de prepared statements et de connexion DB)
    
    deinit {
        fs_db_queue.sync {
            sqlite3_finalize(_recordPointer)
            sqlite3_finalize(_deletePointer)
            sqlite3_finalize(_deleteAllPointer)
            sqlite3_finalize(_readPointer)
            sqlite3_close(_db_opaquePointer)
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
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Error on create url for database"))
            return nil
        }
    }
}
