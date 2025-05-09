//
//  Enums.swift
//  QikiTest
//
//  Created by Miamedia Developer on 22/04/24.
//

import Foundation

enum DisplayMessage: String {
    
    //General Message
    case error = "An error occurred. Please try again."
    case networkError = "Network error detected. \n\nPlease make sure that the device has been connected to internet for smooth operation."
    case badResponse = "Bad response from the server. Please try again."

    //Login Module Message
    case loggingIn = "Logging In..."
    case registeringDevice = "Registering Device..."
    case fetchingStoreDetails = "Preparing store for operations..."
    
    //Checkout
    //Card Transaction
    case transactionInProgress = "Transaction in progress..."
    case cancellingTransaction = "Cancelling Transaction..."
    case transactionCancelled = "Transaction cancelled successfully..."
    case transactionFailed = "Transaction Failed..."
    case transactionCompleted = "Transaction Completed..."
    case transactionStillProgress = "Transaction is still in progress. Waiting for the response..."
    
    //Cash Transactions
    case cashTransactionInProgress = "Cash Transaction in progress..."
    case cashTransactionCompleted = "Cash Transaction Completed..."
    case cashTransactionFailed = "Cash Transaction Failed..."
    
    //Override as paid
    case overrideAsPaid = "Marking order as paid..."
    
    //Orders
    case getOrders = "Fetching Orders..."
    
    //EFTPOS Settings
    case savingEFTPOSSettings = "Saving EFTPOS Settings..."
    case gettingCredentials = "Getting credentials..."
    case pairing = "Pairing is in progress..."
    case checkingPinPadStatus = "Checking Pinpad Status..."
}

enum SetupCompleteDestination: Hashable {
    case appTabView
}

enum CheckoutDestination: Hashable {
    case checkoutView(itemsInDocket: [Product])
}

public enum PaymentMethod: String, Codable, Hashable {
    case card = "Card" //0
    case cash = "Cash" //1
}
