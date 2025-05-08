//
//  EFTPOSViewModel.swift
//  QikiTest
//
//  Created by Miamedia Developer on 18/04/24.
//

import Foundation
import SwiftUI
import Network
import Logger
import Linkly

enum EFTPOSSettingViewState {
    case savingSettings,
         gettingCredentials,
         pairing,
         checkingPinPadStatus,
         error
}

@MainActor
final class EFTPOSViewModel: ObservableObject {
    
    private let repository: EFTPOSRepository
    
    private let terminalRepository: TerminalPairing
    
    @Published var state: EFTPOSSettingViewState = .savingSettings
    
    @Published var moveToNextStep = false
    
    @Published var linklyCredentials = [LinklyCredentials]()
    
    @Published var selectedSerialNumber = UserDefaults.linklySerialNumber != "" ? UserDefaults.linklySerialNumber : "Select Terminal #"
    
    @Published var linklyUserName = "" //UserDefaults.linklyUsername != "" ? UserDefaults.linklyUsername : ""
    
    @Published var linklyPassword = "" //UserDefaults.linklyPassword != "" ? UserDefaults.linklyPassword : ""
    
    @Published var pinPadPairingCode = ""
    
    @Published var isEFTPOSPaired = UserDefaults.eftposPaired == true ? true : false
    
    @Published var pinpadStatus = "Unpaired, not connected..."
    
    @Published var shouldShowPairButton = false
    
    @Published var shouldDisplayPairingCodeGuide = false
    
    @Published public var displayPinpadAlert = false
    
    @Published public var displayErrorAlert = false
    
    @Published var shouldShowCancelButton = false
    
    @Published var alertMessage = ""
    
    @EnvironmentObject var configuration: Configuration
    
    init(repository: EFTPOSRepository) {
        self.repository = repository
        self.terminalRepository = TerminalPairing.init(apiClientService: APIClientService(logger: Logger.init(label: "")))
    }
    
    public func displayMessageOnIndicator() -> String {
        switch state {
            case .savingSettings:
                return DisplayMessage.savingEFTPOSSettings.rawValue
            case .gettingCredentials:
                return DisplayMessage.gettingCredentials.rawValue
            case .pairing:
                return DisplayMessage.pairing.rawValue
            case .checkingPinPadStatus:
                return DisplayMessage.checkingPinPadStatus.rawValue
            case .error:
                return DisplayMessage.error.rawValue
        }
    }
    
    public func resetEFTPOSDetails() {
        pinPadPairingCode = ""
        UserDefaults.linklySecret = ""
        UserDefaults.linklyToken = ""
        UserDefaults.linklyTokenExpiryTime = ""
        UserDefaults.eftposPaired = false
        
        isEFTPOSPaired = false
        updatePairingStatus(withMessage: "")
    }
    
    public func displayUsernamePasswordAlert() {
        alertMessage = "Username or Password is empty. Please enter them to pair EFTPOS."
        shouldShowCancelButton = false
        displayErrorAlert = true

        Log.shared.writeToLogFile(atLevel: .info,
                                  withMessage: "User has not entered either Username or Password or Pairing Code. Hence, I am not letting them to pair with EFTPOS."
        )
    }
    
    public func getCredentails(forLinklyCredentials linklyCredential: LinklyCredentials) {
        let selectedTerminalDetails = linklyCredentials.filter {$0.serialNumber == linklyCredential.serialNumber}
        selectedSerialNumber = selectedTerminalDetails[0].serialNumber
        linklyUserName = selectedTerminalDetails[0].userName
        linklyPassword = selectedTerminalDetails[0].password
    }
    
    public func getCredentials() {
        guard linklyCredentials.count > 0, selectedSerialNumber != "", selectedSerialNumber != "Select Terminal #" else {
            return
        }
        
        linklyUserName = linklyCredentials.filter {$0.serialNumber == selectedSerialNumber}[0].userName
        linklyPassword = linklyCredentials.filter {$0.serialNumber == selectedSerialNumber}[0].password
    }
}

/*
 LinklyCredentials.init(terminalId: "18390394",
                                             serialNumber: "1850479335",
                                             userName: "43800676002",
                                             password: "8RSTCVH4F3X330MS"
                                            ),
                      LinklyCredentials.init(terminalId: "18390395",
                                             serialNumber: "18504893001",
                                             userName: "43800676002",
                                             password: "8RSTCVH4F3X330MS"
                                            ),
                      LinklyCredentials.init(terminalId: "18390396",
                                             serialNumber: "18504893002",
                                             userName: "43800676002",
                                             password: "8RSTCVH4F3X330MS"
                                            ),
                      LinklyCredentials.init(terminalId: "18390397",
                                             serialNumber: "18504893003",
                                             userName: "43800676002",
                                             password: "8RSTCVH4F3X330MS"
                                            ),
 */

extension EFTPOSViewModel {
    public func saveDemoDataIntoDatabase() {
        let linklyDetails = [LinklyCredentials.init(terminalId: "18390398",
                                                    serialNumber: "18504893004",
                                                    userName: "43800676002",
                                                    password: "8RSTCVH4F3X330MS"
                                                   ),
                             LinklyCredentials.init(terminalId: "47804828",
                                                    serialNumber: "1853804549",
                                                    userName: "481007191001",
                                                    password: "W2YJVB5PH65PVCR4"
                                                   )
        ]
        
        saveLinklyCredentials(withLinklyCredentials: linklyDetails)
        linklyCredentials = linklyDetails
    }
}

extension EFTPOSViewModel {
    public func getCredentialsFromDatabase() {
        do {
            linklyCredentials = try repository.fetchLinklyCredentialsFromDatabase()
        } catch {
            //Error logged at repository level.
        }
    }
    
    public func saveLinklyCredentials(withLinklyCredentials credentials: [LinklyCredentials]) {
        do {
            try repository.saveLinklyCredentialsToDatabase(withLinklyCredentialDetails: credentials)
        } catch {
            //Error logged at repository level.
        }
    }
}

extension EFTPOSViewModel {
    //MARK: Change to Pairing Guide
    public func changeInstructionGuide() {
        if shouldDisplayPairingCodeGuide == false && isEFTPOSPaired == false {
            shouldDisplayPairingCodeGuide = true
        }
    }
    
    /// Following function has been used to format the amount that has been entered by User using keypad.
    public func formatAmount(currentText: String,
                             userInput: String
    ) {
        var pairCode = currentText
        
        //backspace registered, need to move the number to the right
        if userInput.isEmpty {
            if pairCode.count > 1 {
                pairCode.remove(at: pairCode.index(before: pairCode.endIndex))
            } else {
                pairCode = ""
            }
        }
        else {
            guard currentText.count < 6 else {
                return
            }

            pairCode.append(userInput)
        }
        
        pinPadPairingCode = pairCode
    }
    
    public func checkAndConfirmPairCode() {
        if pinPadPairingCode.count == 6 {
            shouldShowPairButton = true
        } else {
            alertMessage = "Please enter valid 6 digit pairing code."
            shouldShowCancelButton = false
            displayErrorAlert = true
        }
    }
}

extension EFTPOSViewModel {
    
    func getLinklyCredentials() async {
        state = .gettingCredentials
        Helper.shared.loadingSpinner(isLoading: true,
                                     isUserInteractionEnabled: false,
                                     withMessage: displayMessageOnIndicator()
        )
        
        async let getCredentials = repository.getLinklyCredentails(forSerialNumber: selectedSerialNumber)
        
        guard let credentialDetails = try? await getCredentials else {
            state = .error
            Helper.shared.loadingSpinner(isLoading: false,
                                         isUserInteractionEnabled: true,
                                         withMessage: displayMessageOnIndicator()
            )
            self.shouldShowPairButton = false
            return
        }
        
        Helper.shared.loadingSpinner(isLoading: false,
                                     isUserInteractionEnabled: true,
                                     withMessage: displayMessageOnIndicator()
        )
        
        selectedSerialNumber = credentialDetails.serialNumber
        linklyUserName = credentialDetails.userName
        linklyPassword = credentialDetails.password
    }
    
    func getLinklySecret() async {
        state = .pairing
        Helper.shared.loadingSpinner(isLoading: true,
                                     isUserInteractionEnabled: false,
                                     withMessage: displayMessageOnIndicator()
        )
        
        do {
            async let getLinklyToken = Pairing(isProductionMode: true).initiatePairing(withTerminalNumber: selectedSerialNumber,
                                                                                       andUsername: linklyUserName,
                                                                                       andPassword: linklyPassword,
                                                                                       andPairingCode: pinPadPairingCode,
                                                                                       forPOS: "QIKI",
                                                                                       andPOSVersion: appVersionNumber,
                                                                                       andPOSID: deviceUUID,
                                                                                       andPOSVendorID: "QIKI"
            )
            
            let tokenDetails = try await getLinklyToken
            
            guard tokenDetails.authSecret != "", tokenDetails.authToken != "" else {
                state = .error
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                resetEFTPOSDetails()
                shouldShowPairButton = false
                
                return
            }
            
            pinPadPairingCode = ""
            
            UserDefaults.linklySerialNumber = selectedSerialNumber
            UserDefaults.linklyUsername = linklyUserName
            UserDefaults.linklyPassword = linklyPassword
            UserDefaults.linklySecret = tokenDetails.authSecret
            UserDefaults.linklyToken = tokenDetails.authToken
            UserDefaults.linklyTokenExpiryTime = String().convertDateTimeToString(forSelectedDate: Date().calculateAccessTokenExpiryTime(fromSeconds: tokenDetails.tokenExpiryTime))
            UserDefaults.eftposPaired = true
            
            isEFTPOSPaired = true
            
            Helper.shared.initiateLinklyAccessTokenExpiryCheck()
            
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "New device token is: \(tokenDetails.authToken) and its expiry Date Time is: \(UserDefaults.linklyTokenExpiryTime!)  local time."
            )
            
            Helper.shared.loadingSpinner(isLoading: false,
                                         isUserInteractionEnabled: true,
                                         withMessage: displayMessageOnIndicator()
            )
        } catch APIError.invalidEndpoint {
            print("Invalid end point...")
            Task { @MainActor in
                state = .error
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.error.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
            }
        } catch APIError.badServerResponse {
            print("Bad server response...")
            Task { @MainActor in
                state = .error
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.badResponse.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
            }
        } catch APIError.networkError {
            print("Network error...")
            Task { @MainActor in
                state = .error
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.networkError.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
            }
        } catch APIError.parsing {
            print("Parsing error...")
            Task { @MainActor in
                state = .error
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.error.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
            }
        } catch {
            print("Unkonwn error occurred...")
            Task { @MainActor in
                state = .error
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.error.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
            }
        }
    }
}

extension EFTPOSViewModel {
    
    func checkPinpadStatus() async {
        state = .checkingPinPadStatus
        Helper.shared.loadingSpinner(isLoading: true,
                                     isUserInteractionEnabled: false,
                                     withMessage: displayMessageOnIndicator()
        )
        
        let sessionId = sharedTransaction.generateSessionID()
        do {
            async let checkingStatus = sharedTransaction.checkPinpadStatus(withSessionId: sessionId)
            
            let pinpadStatus = try await checkingStatus
            
            guard pinpadStatus.response.success != false else {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "Pinpad and POS are not connected.")
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                shouldShowPairButton = false
                updatePairingStatus(withMessage: "Pinpad not reachable / offline.")
                alertMessage = "Pinpad and POS are not connected. Please check the status again. \n\nIf the issue persist, contact QIKI Support on 1300 642 633."
                shouldShowCancelButton = false
                displayPinpadAlert = true
                
                return
            }
            
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "Pinpad is connected with POS.")
            
            Helper.shared.loadingSpinner(isLoading: false,
                                         isUserInteractionEnabled: true,
                                         withMessage: displayMessageOnIndicator()
            )
            
            alertMessage = "POS and Pinpad are connected..."
            shouldShowCancelButton = false
            displayPinpadAlert = true
            updatePairingStatus(withMessage: "")
        } catch APIError.invalidEndpoint {
            Task { @MainActor in
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.error.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
                updatePairingStatus(withMessage: "Pinpad not reachable...")
            }
        } catch APIError.badServerResponse {
            Task { @MainActor in
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.badResponse.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
                updatePairingStatus(withMessage: "Pinpad not reachable...")
            }
        } catch APIError.networkError {
            Task { @MainActor in
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.networkError.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
                updatePairingStatus(withMessage: "Pinpad not reachable...")
            }
        } catch APIError.parsing {
            Task { @MainActor in
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.error.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
                updatePairingStatus(withMessage: "Pinpad not reachable...")
            }
        } catch APIError.unknown {
            Task { @MainActor in
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.error.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
            }
        } catch {
            Task { @MainActor in
                Helper.shared.loadingSpinner(isLoading: false,
                                             isUserInteractionEnabled: true,
                                             withMessage: displayMessageOnIndicator()
                )
                
                alertMessage = DisplayMessage.error.rawValue
                shouldShowCancelButton = false
                displayErrorAlert = true
                updatePairingStatus(withMessage: "Pinpad not reachable...")
            }
        }
    }
}

extension EFTPOSViewModel {
    func updatePairingStatus(withMessage message: String) {
        if UserDefaults.eftposPaired && UserDefaults.linklyToken != nil {
            if message == "" {
                pinpadStatus = "Paired, connected..."
            } else {
                pinpadStatus = "Paired, \(message)"
            }
            shouldShowPairButton = true
        } else {
            pinpadStatus = "Unpaired, not connected..."
            shouldShowPairButton = false
        }
    }
}
