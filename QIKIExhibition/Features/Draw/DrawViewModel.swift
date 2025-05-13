//
//  DrawViewModel.swift
//  QIKIExhibition
//
//  Created by Miamedia on 13/5/2025.
//

import Foundation
import SwiftUI
import Network
import Logger
import Linkly
import GRDB

final class DrawViewModel: ObservableObject {
    
    private let repository: DrawRepository
    
    @Published public var name = ""
    
    @Published public var businessName = ""
    
    @Published public var businessPhone = ""
    
    @Published public var businessEmail = ""
    
    @Published var shouldShowPositionList = false

    @Published public var position = ""

    @Published public var selectedPaymentMethod = PaymentMethod.card
    
    @Published public var payButtonTitle = "Pay By Card"
    
    @Published public var transactionAmount = "0.00"
    
    @Published public var shouldShowTransactionView = false

    @Published public var isPaymentPending = false
            
    //Alert
    @Published public var displayErrorAlert = false
    
    @Published public var displaySuccessAlert = false
    
    @Published public var displayNetworkAlert = false
    
    @Published public var shouldShowCancelButton = false
    
    @Published public var alertMessage = ""
        
    init(repository: DrawRepository) {
        self.repository = repository
    }
    
    public func networkAlertMessage() {
        alertMessage = DisplayMessage.networkError.rawValue
        shouldShowCancelButton = false
        displayNetworkAlert = true
    }
}


extension DrawViewModel {
    
    public func saveLeadDetailsToDatabase() async {
        do {
            try repository.saveInquiryDetailsToDatabase(withName: name,
                                                        andBusinessName: businessName,
                                                        andBusinessPhone: businessPhone,
                                                        andBusinessEmail: businessEmail,
                                                        andPosition: position
            )
            
            await saveEnquiryDetailsOnServer()
        } catch {
            //Error logged at repository level...
        }
    }
    
    public func saveEnquiryDetailsOnServer() async {
        if isNetworkReachable() {
            do {
                let allEnquiries = try repository.getEnquieries()
                async let serverResponse = repository.saveInquiryDetails(withEntryDetails: allEnquiries)
                
                guard let serverResponseDetails = try? await serverResponse else {
                    Log.shared.writeToLogFile(atLevel: .error,
                                              withMessage: "Last inquiry detail could not be saved on the server..."
                    )
                    
                    return
                }
                
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Inquiry record details has been stored on the server with \(serverResponseDetails)."
                )
                
                if serverResponseDetails.success == 1 && serverResponseDetails.syncIds != nil && serverResponseDetails.syncIds!.count > 0 {
                    for i in 0 ..< serverResponseDetails.syncIds!.count {
                        try repository.updateSyncStatusToDatabase(for: serverResponseDetails.syncIds![i])
                    }
                }
            } catch APIError.invalidEndpoint {
                print("Invalid end point...")
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Last inquiry record has been stored on the server because of invalid end point."
                )
            } catch APIError.badServerResponse {
                print("Bad server response...")
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Last inquiry record has been stored on the server because of bad server response."
                )
            } catch APIError.networkError {
                print("Network error...")
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Last inquiry record has been stored on the server because of network error."
                )
            } catch APIError.parsing {
                print("Parsing error...")
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Last inquiry record has been stored on the server because of parsing error."
                )
            } catch {
                print("Unkonwn error occurred...")
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Last inquiry record has been stored on the server because of unknonwn error."
                )
            }
        } else {
            networkAlertMessage()
        }
    }
}
