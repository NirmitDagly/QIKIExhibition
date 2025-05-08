//
//  Linkly.swift
//  QikiTest
//
//  Created by Miamedia Developer on 23/12/24.
//

import Foundation
import Network
import GRDB

public struct TransactionModel: Codable, Hashable {
    public var linklyTransactionSessionID: String?
    public var linklyTransactionType: String
    public var linklyTransaction: LinklyTransaction
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case linklyTransactionSessionID
        case linklyTransactionType
        case linklyTransaction
    }
}

public struct LinklyTransaction: Codable, Hashable {
    var id: Int?
    var transactionReferenceId: Int?
    var txnType: String
    var merchant: String
    var cardType: String
    var cardName: String
    var rrn: String
    var dateSettlement: String
    var amtCash: Int
    var amtPurchase: Int
    var amtTip: Int
    var authCode: Int
    var txnRef: String
    var pan: String
    var dateExpiry: String
    var track2: String?
    var accountType: String
    var balanceReceived: Bool
    var availableBalance: Int
    var clearedFundsBalance: Int?
    var success: Bool
    var responseCode: String
    var responseText: String
    var date: String
    var catID: String
    var caID: String
    var stan: Int
    var txnFlags: TransactionFlags
    var purchaseAnalysisData: PurchaseAnalysisData?
    var receipts: [LinklyTransactionReceipts]?
    var dateAdded: Date?
    var dateUpdated: Date?
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case id
        case transactionReferenceId
        case txnType
        case merchant
        case cardType
        case cardName
        case rrn
        case dateSettlement
        case amtCash
        case amtPurchase
        case amtTip
        case authCode
        case txnRef
        case pan
        case dateExpiry
        case track2
        case accountType
        case balanceReceived
        case availableBalance
        case clearedFundsBalance
        case success
        case responseCode
        case responseText
        case date
        case catID
        case caID
        case stan
        case txnFlags
        case purchaseAnalysisData
        case receipts
        case dateAdded
        case dateUpdated
    }
}

struct TransactionFlags: Codable, Hashable {
    var offline: String
    var receiptPrinted: String
    var cardEntry: String
    var commsMethod: String
    var currency: String
    var payPass: String
    var undefinedFlag6: String
    var undefinedFlag7: String
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case offline
        case receiptPrinted
        case cardEntry
        case commsMethod
        case currency
        case payPass
        case undefinedFlag6
        case undefinedFlag7
    }
}

struct PurchaseAnalysisData: Codable, Hashable {
    var rfn: String?
    var ref: String?
    var hrc: String?
    var hrt: String?
    var sur: String?
    var amt: String?
    var cem: String?
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case rfn
        case ref
        case hrc
        case sur
        case amt
        case cem
    }
}

public struct LinklyTransactionReceipts: Codable, Hashable {
    public var type: String
    public var receiptText: [String]
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case type
        case receiptText
    }
}

public struct TransactionReceipt: Codable, Hashable {
    public var responseType: String
    public var response: TransactionReceiptDetails
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case responseType
        case response
    }
}

public struct TransactionReceiptDetails: Codable, Hashable {
    var merchant: String
    var receiptText: [String]
    var success: Bool
    var responseCode: String
    var responseText: String
    
    enum CodingKeys: String, CodingKey, ColumnExpression {
        case merchant
        case receiptText
        case success
        case responseCode
        case responseText
    }
}

extension LinklyTransaction: FetchableRecord, MutablePersistableRecord {
    public static let databaseDateEncodingStrategy = DatabaseDateEncodingStrategy.formatted(Helper.shared.customDateFormatter())
    public static let databaseDateDecodingStrategy = DatabaseDateDecodingStrategy.formatted(Helper.shared.customDateFormatter())

    // Update auto-incremented id upon successful insertion
    mutating public func didInsert(_ inserted: InsertionSuccess) {
        id = Int(inserted.rowID)
    }
}
