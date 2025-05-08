//
//  EFTPOSRepository.swift
//  QikiTest
//
//  Created by Miamedia Developer on 18/04/24.
//

import Foundation
import Network
import GRDB

public protocol QEFTPOSRepository {
    func fetchLinklyCredentialsFromDatabase() throws -> [LinklyCredentials]
    func saveLinklyCredentialsToDatabase(withLinklyCredentialDetails linklyCredentials: [LinklyCredentials]) throws


    func getLinklyCredentails(forSerialNumber serialNumber: String) async throws -> LinklyCredentials
}

public final class EFTPOSRepository: QEFTPOSRepository {
    
    private let apiClientService: APIClientService
    
    public init(apiClientService: APIClientService) {
        self.apiClientService = apiClientService
    }
}

extension EFTPOSRepository {
    public func fetchLinklyCredentialsFromDatabase() throws -> [LinklyCredentials] {
        var linklyCredentials = [LinklyCredentials]()
        
        do {
            try dbPool!.read { db in
                linklyCredentials = try LinklyCredentials.fetchAll(db)
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Failed to fetch linkly credentials with: \(error)"
            )
        }
        return linklyCredentials
    }
    
    public func saveLinklyCredentialsToDatabase(withLinklyCredentialDetails linklyCredentials: [LinklyCredentials]) throws {

        do {
            var recordsToSave = linklyCredentials
            try dbPool!.write { db in
                var lastId = try LinklyCredentials.fetchAll(db).last?.id ?? 0
                
                for i in 0 ..< recordsToSave.count {
                    lastId = lastId + 1
                    recordsToSave[i].id = lastId
                    recordsToSave[i].dateAdded = Date()
                    recordsToSave[i].dateUpdated = Date()
                    
                    try recordsToSave[i].insert(db)
                }
            }
        }  catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Failed to save linkly credentials with: \(error)"
            )
        }
    }
}

extension EFTPOSRepository {
    public func getLinklyCredentails(forSerialNumber serialNumber: String) async throws -> LinklyCredentials {
        try await apiClientService.request(
            APIEndpoints.getLinklyCredentials(forSerialNumber: serialNumber),
            mapper: LinklyCredentialsResponseMapper()
        )
    }
}
