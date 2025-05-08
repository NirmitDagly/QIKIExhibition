//
//  EFTPOSDetails.swift
//  QikiTest
//
//  Created by Miamedia Developer on 06/01/25.
//

import Foundation
import Network
import GRDB

// MARK: - EFTPOS Details
public struct LinklyCredentials: Codable, Hashable {
    var id: Int?
    var terminalId: String
    var serialNumber: String
    var userName: String
    var password: String
    var dateAdded: Date?
    var dateUpdated: Date?
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case id
        case terminalId
        case serialNumber
        case userName
        case password
        case dateAdded
        case dateUpdated
    }
}

extension LinklyCredentials: FetchableRecord, MutablePersistableRecord {
    public static let databaseDateEncodingStrategy = DatabaseDateEncodingStrategy.formatted(Helper.shared.customDateFormatter())
    public static let databaseDateDecodingStrategy = DatabaseDateDecodingStrategy.formatted(Helper.shared.customDateFormatter())

    // Update auto-incremented id upon successful insertion
    mutating public func didInsert(_ inserted: InsertionSuccess) {
        id = Int(inserted.rowID)
    }
}
