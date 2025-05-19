//
//  Repository.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import GRDB
import Network

protocol QEnquiriesRepository {
    func getAllEnquiries() throws -> [InquiryRecordDetails]
    func saveInquiryDetails(withEntryDetails entryDetails: [[String: Any]]) async throws -> InquiryDetails
    
    func getEnquieries() throws -> [[String: Any]]
    func updateSyncStatusToDatabase(for id: Int) throws
}

public final class EnquiriesRepository: QEnquiriesRepository {
    private let apiClientService: APIClientService
    
    public init(apiClientService: APIClientService) {
        self.apiClientService = apiClientService
    }
}

extension EnquiriesRepository {
    
    func getAllEnquiries() throws -> [InquiryRecordDetails] {
        var inquiries = [InquiryRecordDetails]()
        
        do {
            try dbPool!.read { db in
                inquiries = try InquiryRecordDetails.fetchAll(db)
                if inquiries.count > 0 {
                    inquiries = inquiries.sorted(by: {$0.id > $1.id})
                }
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error fetching tax groups from database: \(error)"
            )
        }
        
        return inquiries
    }
    
}

extension EnquiriesRepository {
    public func getEnquieries() throws -> [[String: Any]] {
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
    
    public func updateSyncStatusToDatabase(for id: Int) throws {
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
    
    public func saveInquiryDetails(withEntryDetails entryDetails: [[String: Any]]) async throws -> InquiryDetails {
        try await apiClientService.request(
            APIEndpoints.saveCompetitionEntry(for: entryDetails),
            mapper: InquiryDetailsResponseMapper()
        )
    }
}
