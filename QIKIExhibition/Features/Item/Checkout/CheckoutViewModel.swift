//
//  CheckoutViewModel.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import SwiftUI
import Network
import Logger
import Linkly
import GRDB

enum CheckoutViewState {
    case overrideAsPaid
    case error
}

enum FocusableField {
    case name
    case businessName
    case businessPhone
    case businessEmail
    case position
}

final class CheckoutViewModel: ObservableObject {
    
    private let repository: CheckoutRepository
    
    @Published public var itemsInDocket = [Product]()
    
    @Published public var subTotal = "0.00"
    
    @Published public var totalPayableAmount = "0.00"
    
    @Published public var name = ""
    
    @Published public var businessName = ""
    
    @Published public var businessPhone = ""
    
    @Published public var businessEmail = ""
    
    @Published public var positionList = ["Owner",
                                          "Co-owner",
                                          "CEO",
                                          "COO",
                                          "CFO",
                                          "CTO",
                                          "Director",
                                          "Executive Director",
                                          "CA",
                                          "Accountant",
                                          "Staff"
    ]
    
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
        
    init(repository: CheckoutRepository) {
        self.repository = repository
    }
}

extension CheckoutViewModel {
    
    public func updatePaymentMethodOnSelection(paymentMethod: Int) {
        if paymentMethod == 0 {
            selectedPaymentMethod = PaymentMethod.card
        } else {
            selectedPaymentMethod = PaymentMethod.cash
        }
        
        getPayButtonTitle()
    }
    
    //MARK: Change 'Pay' button title on change of payment method
    public func getPayButtonTitle() {
        if selectedPaymentMethod == PaymentMethod.card {
            payButtonTitle = "Pay By \(PaymentMethod.card.rawValue)"
        } else {
            payButtonTitle = "Pay By \(PaymentMethod.cash.rawValue)"
        }
    }
    
    //MARK: Calculate final payable amount
    public func finalPayableAmount() {
        transactionAmount = Calculator.shared.calculateSubTotal(forProductsInCart: itemsInDocket)
    }
}

extension CheckoutViewModel {
    
    public func saveLeadDetailsToDatabase() {
        do {
            try repository.saveInquiryDetails(withName: name,
                                              andBusinessName: businessName,
                                              andBusinessPhone: businessPhone,
                                              andBusinessEmail: businessEmail,
                                              andPosition: position
            )
        } catch {
            //Error logged at repository level...
        }
    }
}

//Extension for Override as paid
extension CheckoutViewModel {
    
    //MARK: Mark order override as paid
    public func markOrderAsPaid() {
        do {
            try repository.saveInquiryDetails(withName: name,
                                              andBusinessName: businessName,
                                              andBusinessPhone: businessPhone,
                                              andBusinessEmail: businessEmail,
                                              andPosition: position
            )
        } catch {
            //Error logged at repository level.
        }
    }
}

