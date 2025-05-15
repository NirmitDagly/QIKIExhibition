//
//  Endpoint.swift
//  QIKIExhibition
//
//  Created by Miamedia on 9/5/2025.
//

import Foundation
import Network

extension APIEndpoints {
    static func saveCompetitionEntry(for entryDetails: [[String: Any]]) -> APIEndpoint {
        return .init(
            path: "/Services/DrawEntry",
            httpMethod: .post,
            //headers: ["apiKey": UserDefaults.accessToken],
            bodyParameter: .dictionary(["entries": entryDetails],
                                       options: .prettyPrinted
                                      )
            )
    }
    
    static func saveCompetitionEntryWithOneEntry(for entryDetails: [String: Any]) -> APIEndpoint {
        return .init(
            path: "/Services/DrawEntry",
            httpMethod: .post,
            //headers: ["apiKey": UserDefaults.accessToken],
            bodyParameter: .dictionary(entryDetails,
                                       options: .prettyPrinted
                                      )
            )
    }
}

public struct InquiryDetails: Codable {
    public var success: Bool
    public var message: String?
    public var syncIds: [Int]?
}

public struct InquiryDetailsResponse: Codable {
    public var success: Bool
    public var message: String?
    public var syncIds: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case syncIds = "entries"
    }
}

public struct InquiryDetailsResponseMapper: Mappable {
    public func map(_ input: InquiryDetailsResponse) throws -> InquiryDetails {
        return .init(success: input.success,
                     message: input.message ?? "",
                     syncIds: input.syncIds ?? [0]
        )
    }
}
