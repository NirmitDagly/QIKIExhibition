//
//  InquiryRecordsResponse.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import Network

public struct InquiryRecordDetailsResponse: Codable, Hashable {
    public var id: Int
    public var name: String
    public var businessName: String
    public var businessPhone: String
    public var businessEmail: String
    public var position: String
    public var syncStatus: Int
    public var dateAdded: Date?
    public var dateUpdated: Date?
}

public struct InquiryRecordDetailsResponseMapper: Mappable {
    public func map(_ input: InquiryRecordDetailsResponse) throws -> InquiryRecordDetails {
        return .init(id: input.id,
                     name: input.name,
                     businessName: input.businessName,
                     businessPhone: input.businessPhone,
                     businessEmail: input.businessEmail,
                     position: input.position,
                     syncStatus: input.syncStatus,
                     dateAdded: input.dateAdded,
                     dateUpdated: input.dateUpdated
        )
    }
}
