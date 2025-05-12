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
            path: "/saveCompetitionEntry",
            httpMethod: .post,
            //headers: ["apiKey": UserDefaults.accessToken],
            bodyParameter: .dictionary(["entryDetails": entryDetails],
                                       options: .prettyPrinted
                                      )
            )
    }   
}

public struct InquiryDetails: Codable {
    public var success: Int
    public var message: String
    public var syncIds: [Int]?
}

public struct InquiryDetailsResponse: Codable {
    public var success: Int
    public var message: String
    public var syncIds: [Int]?
}

public struct InquiryDetailsResponseMapper: Mappable {
    public func map(_ input: InquiryDetailsResponse) throws -> InquiryDetails {
        return .init(success: input.success,
                     message: input.message,
                     syncIds: input.syncIds ?? [0]
        )
    }
}
