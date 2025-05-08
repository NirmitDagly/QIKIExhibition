//
//  DBOperation.swift
//  QikiTest
//
//  Created by Nirmit Dagly on 28/11/2024.
//

import Foundation
import GRDB
import Logger

public class DBOperation {
    
    static let shared = DBOperation()
    
    func checkDatabase() throws -> Bool {
        var dbExists = false

        let fileManager = FileManager.default
        do {
            let appSupportURL = try fileManager.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true
            )
            
            let directoryURL = appSupportURL.appendingPathComponent("Database/Qiki.sqlite",
                                                                    isDirectory: false
            )
            
            if fileManager.fileExists(atPath: directoryURL.path) {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Database exist at \(directoryURL.path)."
                )
                try openDatabase(atPath: directoryURL.path)
                dbExists = true
            } else {
                Log.shared.writeToLogFile(atLevel: .error,
                                          withMessage: "Database does not exist."
                )
                
                dbExists = false
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error: \(error)"
            )
        }
        
        return dbExists
    }
    
    func createDatabase() throws {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true
            )
            
            let directoryURL = appSupportURL.appendingPathComponent("Database",
                                                                    isDirectory: true
            )
            
            try fileManager.createDirectory(at: directoryURL,
                                            withIntermediateDirectories: true
            )
            
            let databaseURL = directoryURL.appendingPathComponent("Qiki.sqlite")
            try openDatabase(atPath: databaseURL.absoluteString)
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error creating database directory or opening database: \(error)"
            )
        }
    }
    
    func openDatabase(atPath path: String) throws {
        do {
            dbPool = try DatabasePool(path: path)
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error creating database directory or opening database: \(error)"
            )
        }
    }
    
    func closeDatabase() {
        guard dbPool != nil else {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Database pool is nil. Cannot close database."
            )
            return
        }
        
        do {
            try dbPool!.close()
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error closing database: \(error)"
            )
        }
    }
    
    func checkForDatabaseConnection() -> Bool {
        guard dbPool != nil else {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Database pool is nil. Cannot close database."
            )
            return false
        }
        
        return true
    }
}
