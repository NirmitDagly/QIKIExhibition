//
//  LinklyResponse.swift
//  QikiTest
//
//  Created by Miamedia Developer on 23/12/24.
//

import Foundation
import Network

public struct TransactionReceiptResponse: Codable {
    public var responseType: String
    public var response: TransactionReceiptDetailsResponse

    enum CodingKeys: String, CodingKey {
        case responseType = "responseType"
        case response = "response"
    }
}

struct TransactionReceiptResponseMapper: Mappable {
    
    func map(_ input: TransactionReceiptResponse) throws -> TransactionReceipt {
        return .init(responseType: input.responseType,
                     response: try TransactionReceiptDetailsResponseMapper().map(input.response)
        )
    }
}

public struct TransactionReceiptDetailsResponse: Codable {
    var merchant: String
    var receiptText: [String]
    var success: Bool
    var responseCode: String
    var responseText: String
    
    enum CodingKeys: String, CodingKey {
        case merchant
        case receiptText
        case success
        case responseCode
        case responseText
    }
}

struct TransactionReceiptDetailsResponseMapper: Mappable {
    func map(_ input: TransactionReceiptDetailsResponse) throws -> TransactionReceiptDetails {
        return .init(merchant: input.merchant,
                     receiptText: input.receiptText,
                     success: input.success,
                     responseCode: input.responseCode,
                     responseText: input.responseText
        )
    }
}
