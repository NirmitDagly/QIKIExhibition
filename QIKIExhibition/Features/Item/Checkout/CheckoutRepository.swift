//
//  CheckoutRepository.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import Network
import GRDB

public protocol QCheckoutRepository {
    
    func saveInquiryDetails(withName name: String,
                            andBusinessName businessName: String,
                            andBusinessPhone businessPhone: String,
                            andBusinessEmail email: String,
                            andPosition position: String
    ) throws
    
    func saveInquiryDetailsOnServer(withName name: String,
                                    andBusinessName businessName: String,
                                    andBusinessPhone businessPhone: String,
                                    andBusinessEmail email: String,
                                    andPosition position: String
    ) async throws -> InquiryDetails
}

public final class CheckoutRepository: QCheckoutRepository {
    
    private let apiClientService: APIClientService
    
    public init(apiClientService: APIClientService) {
        self.apiClientService = apiClientService
    }
}

extension CheckoutRepository {
    
    public func saveInquiryDetails(withName name: String,
                                   andBusinessName businessName: String,
                                   andBusinessPhone businessPhone: String,
                                   andBusinessEmail email: String,
                                   andPosition position: String
    ) throws {
        do {
            try dbPool!.write { db in
                let lastId = try InquiryRecordDetails.fetchAll(db).last?.id ?? 0
                var leadDetails = InquiryRecordDetails(id: lastId + 1,
                                                       name: name,
                                                       businessName: businessName,
                                                       businessPhone: businessPhone,
                                                       businessEmail: email,
                                                       position: position,
                                                       dateAdded: Date(),
                                                       dateUpdated: Date()
                )
                
                try leadDetails.insert(db)
            }
        }
    }
}

extension CheckoutRepository {
    
    public func saveInquiryDetailsOnServer(withName name: String,
                                           andBusinessName businessName: String,
                                           andBusinessPhone businessPhone: String,
                                           andBusinessEmail email: String,
                                           andPosition position: String
    ) async throws -> InquiryDetails {
        try await apiClientService.request(
            APIEndpoints.saveCompetitionEntry(withName: name,
                                              andBusinessName: businessName,
                                              andBusinessEmail: email,
                                              andPhoneNumber: businessPhone,
                                              andPosition: position
                                            ),
            mapper: InquiryDetailsResponseMapper()
        )
    }
}
