//
//  Endpoint.swift
//  QIKIExhibition
//
//  Created by Miamedia on 9/5/2025.
//

import Foundation
import Network

extension APIEndpoints {
    static func saveCompetitionEntry(withName name: String,
                                     andBusinessName businessName: String,
                                     andBusinessEmail email: String,
                                     andPhoneNumber phone: String,
                                     andPosition position: String
    ) -> APIEndpoint {
        return .init(
            path: "/saveCompetitionEntry",
            httpMethod: .post,
            bodyParameter: .dictionary(["name": name,
                                        "businessName": businessName,
                                        "businessEmail": email,
                                        "businessPhone": phone,
                                        "position": position
                                       ],
                                       options: .prettyPrinted)
        )
    }
}

public struct InquiryDetails: Codable {
    public var success: Int
    public var message: String
}

public struct InquiryDetailsResponse: Codable {
    public var success: Int
    public var message: String
}

public struct InquiryDetailsResponseMapper: Mappable {
    public func map(_ input: InquiryDetailsResponse) throws -> InquiryDetails {
        return .init(success: input.success,
                     message: input.message
        )
    }
}
