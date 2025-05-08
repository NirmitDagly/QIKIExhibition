//
//  InquiryRecords.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import GRDB

public struct InquiryRecordDetails: Codable {
    public var id: Int
    public var name: String
    public var businessName: String
    public var businessPhone: String
    public var businessEmail: String
    public var position: String
    public var dateAdded: Date?
    public var dateUpdated: Date?
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case id
        case name
        case businessName
        case businessPhone
        case businessEmail
        case position
        case dateAdded
        case dateUpdated
    }
}

extension InquiryRecordDetails: FetchableRecord, MutablePersistableRecord {
    public static let databaseDateEncodingStrategy = DatabaseDateEncodingStrategy.formatted(Helper.shared.customDateFormatter())
    public static let databaseDateDecodingStrategy = DatabaseDateDecodingStrategy.formatted(Helper.shared.customDateFormatter())

    // Update auto-incremented id upon successful insertion
    mutating public func didInsert(_ inserted: InsertionSuccess) {
        id = Int(inserted.rowID)
    }
}
