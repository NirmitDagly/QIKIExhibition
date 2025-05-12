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
    
    func saveInquiryDetailsOnServer(withEntryDetails entryDetails: [InquiryRecordDetails]) async throws -> InquiryDetails
    func getEnquieriesFromDatabase() throws -> [InquiryRecordDetails]
    func updateSyncStats(for id: Int) throws
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
                                                       syncStatus: 0,
                                                       dateAdded: Date(),
                                                       dateUpdated: Date()
                )
                
                try leadDetails.insert(db)
            }
        }
    }
    
    public func getEnquieriesFromDatabase() throws -> [InquiryRecordDetails] {
        var enquieries: [InquiryRecordDetails] = [InquiryRecordDetails]()
        do {
            try dbPool!.read { db in
                enquieries = try InquiryRecordDetails.filter(Column("syncStatus") == 0).fetchAll(db)
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "An error occurred while fetching all records from database which are not synced to server.")
        }
        
        return enquieries
    }
    
    public func updateSyncStats(for id: Int) throws {
        do {
            try dbPool!.write { db in
                if let record = try InquiryRecordDetails.filter(Column("id") == id).fetchOne(db) {
                    var updatedRecord = record
                    updatedRecord.syncStatus = 1
                    try updatedRecord.update(db)
                }
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "An error occurred while updating sync status for enquiery record with id: \(id)."
            )
        }
    }
}

extension CheckoutRepository {
    
    public func saveInquiryDetailsOnServer(withEntryDetails entryDetails: [InquiryRecordDetails]) async throws -> InquiryDetails {
        try await apiClientService.request(
            APIEndpoints.saveCompetitionEntry(for: entryDetails),
            mapper: InquiryDetailsResponseMapper()
        )
    }
}
