//
//  CreateTables.swift
//  QikiTest
//
//  Created by Nirmit Dagly on 28/11/2024.
//

public class CreateTables {
    
    static let shared = CreateTables()
    
    func createTables() {
        guard DBOperation.shared.checkForDatabaseConnection() != false else {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Could not create tables. No database connection."
            )
            return
        }

        //Lead related tables
        createEnquiriesTable()
        
        //EFTPOS Settings related tables
        createEFTPOSSettingsTable()
    }
    
    //MARK: App related table
    func createEnquiriesTable() {
        do {
            try dbPool!.write { db in
                try db.create(table: "InquiryRecordDetails",
                              options: [.ifNotExists]
                ) { t in
                    t.autoIncrementedPrimaryKey("id").notNull().unique()
                    t.column("name", .text)
                    t.column("businessName", .text)
                    t.column("businessPhone", .text)
                    t.column("businessEmail", .text)
                    t.column("position", .text)
                    t.column("dateAdded", .datetime)
                    t.column("dateUpdated", .datetime)
                }
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error creating AppDetail table: \(error)"
            )
        }
    }

    //MARK: EFTPOS Tables
    func createEFTPOSSettingsTable() {
        do {
            try dbPool!.write { db in
                try db.create(table: "linklyCredentials",
                              options: [.ifNotExists]
                ) { t in
                    t.autoIncrementedPrimaryKey("id").notNull().unique()
                    t.column("terminalId", .text)
                    t.column("serialNumber", .text)
                    t.column("userName", .text)
                    t.column("password", .text)
                    t.column("dateAdded", .datetime)
                    t.column("dateUpdated", .datetime)
                }
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error creating CashoutReport table: \(error)"
            )
        }
    }
}
