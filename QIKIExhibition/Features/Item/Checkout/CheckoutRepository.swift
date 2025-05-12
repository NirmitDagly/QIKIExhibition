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
    
    func saveInquiryDetailsOnServer(withEntryDetails entryDetails: [[String: Any]]) async throws -> InquiryDetails
    func getEnquieriesFromDatabase() throws -> [[String: Any]]
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
    
    public func getEnquieriesFromDatabase() throws -> [[String: Any]] {
        var allEnquieries = [[String: Any]]()
        do {
            try dbPool!.read { db in
                let enquieries = try InquiryRecordDetails.filter(Column("syncStatus") == 0).fetchAll(db)
                
                if enquieries.count > 0 {
                    for i in 0 ..< enquieries.count {
                        let inquiry = ["clientEntryId": enquieries[i].id,
                                       "name": enquieries[i].name,
                                       "businessName": enquieries[i].businessName,
                                       "businessPhone": enquieries[i].businessPhone,
                                       "businessEmail": enquieries[i].businessEmail,
                                       "position": enquieries[i].position
                        ]
                                       
                        allEnquieries.append(inquiry)
                    }
                }
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "An error occurred while fetching all records from database which are not synced to server.")
        }
        
        return allEnquieries
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
    
    public func saveInquiryDetailsOnServer(withEntryDetails entryDetails: [[String: Any]]) async throws -> InquiryDetails {
        try await apiClientService.request(
            APIEndpoints.saveCompetitionEntry(for: entryDetails),
            mapper: InquiryDetailsResponseMapper()
        )
    }
}
