//
//  EnquiriesViewModel.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import Logger
import Network

final class EnquiriesViewModel: ObservableObject {
    
    @Published public var selectedDate = Date()
    
    @Published public var enquiries = [InquiryRecordDetails]()
    
    private let repository: EnquiriesRepository
    
    //Alert
    @Published public var displayPasswordAlert = false
    
    @Published public var displayErrorAlert = false
    
    @Published public var displaySuccessAlert = false
    
    @Published public var displayNetworkAlert = false
    
    @Published public var shouldShowCancelButton = false
    
    @Published public var alertMessage = ""
    
    @Published public var passwordAlertMessage = "Please enter your password to view enquiries."
    
    init(repository: EnquiriesRepository) {
        self.repository = repository
    }
    
    func successMessage() {
        alertMessage = "Enquiries synced successfully on CRM."
        shouldShowCancelButton = false
        displaySuccessAlert = true
    }
}

extension EnquiriesViewModel {
    
    public func getAllEnquiries() {
        do {
            enquiries = try repository.getAllEnquiries()
        } catch {
            //Error logged at repository level.
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
                
                DispatchQueue.main.async { [weak self] in
                    self?.successMessage()
                }
                
                if serverResponseDetails.success == true && serverResponseDetails.syncIds != nil && serverResponseDetails.syncIds!.count > 0 {
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
        }
    }
    
    public func networkAlertMessage() {
        alertMessage = DisplayMessage.networkError.rawValue
        shouldShowCancelButton = false
        displayNetworkAlert = true
    }
}
