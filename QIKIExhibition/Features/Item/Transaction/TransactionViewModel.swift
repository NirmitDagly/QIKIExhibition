//
//  TransactionViewModel.swift
//  QikiTest
//
//  Created by Miamedia Developer on 22/08/24.
//

import Foundation
import SwiftUI
import Network
import Logger
import Linkly

enum TransactionViewState {
    case transactionInProgress, 
         cancellingTransaction,
         transactionCancelled,
         transactionFailed,
         transactionCompleted,
         transactionStillProgress,
         error
}

final class TransactionViewModel: ObservableObject {
    
    @Published var shouldShowCancelButton = true
    
    @Published var state: TransactionViewState = .transactionInProgress
    
    @Published var transactionAmount = "0.00"
    
    @Published var shouldNavigateBack = false
    
    let checkoutViewModel: CheckoutViewModel
    
    init(withCheckoutViewModel checkoutViewModel: CheckoutViewModel) {
        self.checkoutViewModel = checkoutViewModel
    }

    //MARK: Display appropriate messages on the indicator
    func displayMessageOnIndicator() -> String {
        switch state {
            case .transactionInProgress:
                return DisplayMessage.transactionInProgress.rawValue
            case .cancellingTransaction:
                return DisplayMessage.cancellingTransaction.rawValue
            case .transactionCancelled:
                return DisplayMessage.transactionCancelled.rawValue
            case .transactionFailed:
                return DisplayMessage.transactionFailed.rawValue
            case .transactionCompleted:
                return DisplayMessage.transactionCompleted.rawValue
            case .transactionStillProgress:
                return DisplayMessage.transactionStillProgress.rawValue
            case .error:
                return DisplayMessage.error.rawValue
        }
    }
}

extension TransactionViewModel {
    
    //MARK: Initiate payment with Linkly and handle payment
    @MainActor
    func initiatePaymentWithLinkly() async throws {
        state = .transactionInProgress
        
        Task {
            let sessionId = sharedTransaction.generateSessionID()
            UserDefaults.linklySessionId = sessionId
            
            let txnRefNumber = sharedTransaction.getTransactionReferenceNumber()
            
            do {
                async let getTransactionResponse = sharedTransaction.initiatePaymentWithLinkly(withSessionId: UserDefaults.linklySessionId,
                                                                                               forPurchaseAmount: transactionAmount.replacingOccurrences(of: ".", with: ""),
                                                                                               andTxnRefNumber: txnRefNumber
                )
                
                let transactionResponseDetails = try await getTransactionResponse
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Transaction details received for: \(transactionResponseDetails)."
                )
                
                if transactionResponseDetails.linklyTransaction.responseText.localizedCaseInsensitiveContains("APPROVED") {
                    checkoutViewModel.saveLeadDetailsToDatabase()
                    state = .transactionCompleted
                    
                    if checkoutViewModel.isPaymentPending == false  {
                        shouldNavigateBack = true
                    }
                } else if transactionResponseDetails.linklyTransaction.responseText.localizedCaseInsensitiveContains("OPERATOR CANCELLED") {
                    state = .transactionCancelled
                } else {
                    state = .error
                }
                
                shouldShowCancelButton = false
                UserDefaults.linklySessionId = ""
            } catch APIError.invalidEndpoint {
                throw APIError.invalidEndpoint
            } catch APIError.badServerResponse {
                throw APIError.badServerResponse
            } catch APIError.networkError {
                throw APIError.networkError
            } catch APIError.parsing {
                throw APIError.parsing
            } catch APIError.unknown {
                throw APIError.unknown
            } catch {
                throw APIError.badServerResponse
            }
        }
    }
        
    @MainActor
    func cancelPaymentWithLinkly() async throws {
        state = .cancellingTransaction
        Task {
            do {
                async let getTransactionResponse = sharedTransaction.cancelPaymentWithLinkly(withSessionId: UserDefaults.linklySessionId,
                                                                                             andTxnRefNumber: ""
                )
                
                let transactionResponseDetails = try await getTransactionResponse
                
                guard transactionResponseDetails.localizedCaseInsensitiveContains("Unknown") else {
                    state = .error
                    Log.shared.writeToLogFile(atLevel: .info,
                                              withMessage: "Transaction failed for amount: \(transactionAmount).")
                    return
                }
                
                shouldShowCancelButton = false
            } catch APIError.invalidEndpoint {
                throw APIError.invalidEndpoint
            } catch APIError.badServerResponse {
                throw APIError.badServerResponse
            } catch APIError.networkError {
                throw APIError.networkError
            } catch APIError.parsing {
                throw APIError.parsing
            } catch APIError.unknown {
                throw APIError.unknown
            } catch {
                throw APIError.badServerResponse
            }
        }
    }
        
    func convertLinklyTransactionReceipts(forTransactionResponse transactionResponseDetails: Linkly.TransactionModel) -> [LinklyTransactionReceipts] {
        var transactionReceipts = [LinklyTransactionReceipts]()
        
        if transactionResponseDetails.linklyTransaction.receipts != nil &&
            transactionResponseDetails.linklyTransaction.receipts!.count > 0 {
            for i in 0 ..< transactionResponseDetails.linklyTransaction.receipts!.count {
                let receipt = LinklyTransactionReceipts(type: transactionResponseDetails.linklyTransaction.receipts![i].type,
                                                        receiptText: transactionResponseDetails.linklyTransaction.receipts![i].receiptText
                )
                transactionReceipts.append(receipt)
            }
        }
        
        return transactionReceipts
    }
        
    func convertLinklyTransaction(forTransactionResponse transactionResponseDetails: Linkly.TransactionModel) -> LinklyTransaction {
        let convertedReceipts = convertLinklyTransactionReceipts(forTransactionResponse: transactionResponseDetails)
        let transaction = LinklyTransaction(txnType: transactionResponseDetails.linklyTransaction.txnType,
                                            merchant: transactionResponseDetails.linklyTransaction.merchant,
                                            cardType: transactionResponseDetails.linklyTransaction.cardType,
                                            cardName: transactionResponseDetails.linklyTransaction.cardName,
                                            rrn: transactionResponseDetails.linklyTransaction.rrn,
                                            dateSettlement: transactionResponseDetails.linklyTransaction.dateSettlement,
                                            amtCash: transactionResponseDetails.linklyTransaction.amtCash,
                                            amtPurchase: transactionResponseDetails.linklyTransaction.amtPurchase,
                                            amtTip: transactionResponseDetails.linklyTransaction.amtTip,
                                            authCode: transactionResponseDetails.linklyTransaction.authCode,
                                            txnRef: transactionResponseDetails.linklyTransaction.txnRef,
                                            pan: transactionResponseDetails.linklyTransaction.pan,
                                            dateExpiry: transactionResponseDetails.linklyTransaction.dateExpiry,
                                            accountType: transactionResponseDetails.linklyTransaction.accountType,
                                            balanceReceived: transactionResponseDetails.linklyTransaction.balanceReceived,
                                            availableBalance: transactionResponseDetails.linklyTransaction.availableBalance,
                                            success: transactionResponseDetails.linklyTransaction.success,
                                            responseCode: transactionResponseDetails.linklyTransaction.responseCode,
                                            responseText: transactionResponseDetails.linklyTransaction.responseText,
                                            date: transactionResponseDetails.linklyTransaction.date,
                                            catID: transactionResponseDetails.linklyTransaction.catID,
                                            caID: transactionResponseDetails.linklyTransaction.caID,
                                            stan: transactionResponseDetails.linklyTransaction.stan,
                                            txnFlags: TransactionFlags(offline: transactionResponseDetails.linklyTransaction.txnFlags.offline,
                                                                       receiptPrinted: transactionResponseDetails.linklyTransaction.txnFlags.receiptPrinted,
                                                                       cardEntry: transactionResponseDetails.linklyTransaction.txnFlags.cardEntry,
                                                                       commsMethod: transactionResponseDetails.linklyTransaction.txnFlags.commsMethod,
                                                                       currency: transactionResponseDetails.linklyTransaction.txnFlags.currency,
                                                                       payPass: transactionResponseDetails.linklyTransaction.txnFlags.payPass,
                                                                       undefinedFlag6: transactionResponseDetails.linklyTransaction.txnFlags.undefinedFlag6,
                                                                       undefinedFlag7: transactionResponseDetails.linklyTransaction.txnFlags.undefinedFlag7
                                                                      ),
                                            purchaseAnalysisData: PurchaseAnalysisData(rfn: transactionResponseDetails.linklyTransaction.purchaseAnalysisData?.rfn,
                                                                                       ref: transactionResponseDetails.linklyTransaction.purchaseAnalysisData?.ref,
                                                                                       hrc: transactionResponseDetails.linklyTransaction.purchaseAnalysisData?.hrc,
                                                                                       hrt: transactionResponseDetails.linklyTransaction.purchaseAnalysisData?.hrt,
                                                                                       sur: transactionResponseDetails.linklyTransaction.purchaseAnalysisData?.sur,
                                                                                       amt: transactionResponseDetails.linklyTransaction.purchaseAnalysisData?.amt,
                                                                                       cem: transactionResponseDetails.linklyTransaction.purchaseAnalysisData?.cem
                                                                                      ),
                                            receipts: convertedReceipts
        )
        
        return transaction
    }
}
