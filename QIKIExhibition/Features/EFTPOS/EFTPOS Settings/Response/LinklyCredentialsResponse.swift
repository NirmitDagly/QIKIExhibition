//
//  LinklyCredentialsResponse.swift
//  QikiTest
//
//  Created by Miamedia Developer on 30/08/24.
//

import Foundation
import Network

public struct LinklyCredentialsResponse: Codable {
    public var id: Int?
    public var terminalId: String
    public var serialNumber: String
    public var userName: String
    public var password: String
    public var dateAdded: Date?
    public var dateUpdated: Date?
}

public struct LinklyCredentialsResponseMapper: Mappable {
    public func map(_ input: LinklyCredentialsResponse) throws -> LinklyCredentials {
        return .init(id: input.id,
                     terminalId: input.terminalId,
                     serialNumber: input.serialNumber,
                     userName: input.userName,
                     password: input.password,
                     dateAdded: input.dateAdded,
                     dateUpdated: input.dateUpdated
        )
    }
}
