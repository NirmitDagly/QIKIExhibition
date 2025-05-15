//
//  Helper.swift
//  QikiTest
//
//  Created by Miamedia Developer on 14/3/2024.
//

import Foundation
import SwiftUI
import Network
import NVActivityIndicatorView
import DesignSystem
import Linkly
import GRDB
import Logger

public class Helper {
    
    static let shared = Helper()
    
    let refreshToken = RefreshLinklyToken()
    
    func getAppVersionNumber() -> String {
        return appVersionNumber + ":" + appBuildNumber
    }
    
    func loadingSpinner(isLoading: Bool,
                        isUserInteractionEnabled: Bool,
                        withMessage message: String
    ) {
        spinnerActive = isLoading
        let connectedScence = UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }.compactMap { $0 as? UIWindowScene }
        let window = connectedScence.first?.windows.first {$0.isKeyWindow}
        //        var loader: FillableLoader = FillableLoader()
        
        let loadingView = UIView(frame: CGRect(x: 0, 
                                               y: 0,
                                               width: 240,
                                               height: 150
                                              )
        )
        loadingView.center = window!.center
        
        let spinnerFrame = CGRect(x: 30,
                                  y: 10,
                                  width: 60,
                                  height: 60
        )
        let spinner = NVActivityIndicatorView(frame: spinnerFrame, 
                                              type: .ballBeat,
                                              color: UIColor(Color.qikiColor),
                                              padding: 0
        )
        
        let messageLabel = UILabel.init(frame: CGRect.init(x: loadingView.frame.origin.x, 
                                                           y: 70,
                                                           width: 240,
                                                           height: 60
                                                          )
        )
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        messageLabel.numberOfLines = 2
        messageLabel.textColor = .black
        messageLabel.textAlignment = .center
        messageLabel.tag = 101
        
        for subview in window!.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        loadingView.addSubview(spinner)
        if message != "" {
            loadingView.addSubview(messageLabel)
        }
        window!.addSubview(loadingView)
        
        loadingView.tag = 100
        
        loadingView.layer.cornerRadius = 15
        loadingView.backgroundColor = #colorLiteral(red: 0.5480879545, green: 0.5448333025, blue: 0.5505920649, alpha: 0.3553896266)
        loadingView.alpha = 1
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 120),
            spinner.heightAnchor.constraint(equalToConstant: 120),
            spinner.centerYAnchor.constraint(equalTo: window!.centerYAnchor, constant: -50),
            spinner.centerXAnchor.constraint(equalTo: window!.centerXAnchor),
        ])
        
        if message != "" {
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                messageLabel.widthAnchor.constraint(equalToConstant: 240),
                messageLabel.heightAnchor.constraint(equalToConstant: 60),
                messageLabel.topAnchor.constraint(equalTo: spinner.topAnchor, constant: 70),
                messageLabel.centerXAnchor.constraint(equalTo: window!.centerXAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalToConstant: 240),
            loadingView.heightAnchor.constraint(equalToConstant: 150),
            loadingView.centerYAnchor.constraint(equalTo: window!.centerYAnchor, constant: -50),
            loadingView.centerXAnchor.constraint(equalTo: window!.centerXAnchor),
        ])
        
        if isLoading == true {
            spinner.startAnimating()
            //            loader = PlainLoader.showLoader(with: qikiLogoPath(), on: window!.subviews.first)
            //            loadingView.addSubview(loader)
            window!.isUserInteractionEnabled = isUserInteractionEnabled
        } else {
            for subview in window!.subviews {
                if subview.tag == 100 {
                    //                    loader.removeLoader(true)
                    subview.removeFromSuperview()
                }
            }
            spinner.stopAnimating()
            window!.isUserInteractionEnabled = true
        }
    }
    
    func customDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        
        return dateFormatter
    }
    
    //MARK: Wrap text based on character limit to display on screen / to print on docket
    func wrapTextAndDisplay(textData: String) -> String {
        var wrappedText = ""
        var table = textData.split(separator: " ")
        
        let limit = 20
        var tempString = ""
        
        var finalResult: [String] = []
        
        for i in 0 ..< table.count {
            for item in table {
                if tempString.count + item.count < limit {
                    tempString += item + " "
                    if finalResult.isEmpty {
                        finalResult.append(tempString)
                    }
                    else {
                        finalResult[i] = tempString
                    }
                    
                    if table.count > 0 {
                        table.removeFirst()
                    }
                    
                    if table.count == 0 {
                        break
                    }
                }
                else {
                    tempString = "\n"
                    finalResult.append("")
                    break
                }
            }
        }
        
        if finalResult.count > 0 {
            for j in 0 ..< finalResult.count {
                wrappedText = wrappedText + finalResult[j]
            }
        }
        
        return wrappedText
    }

    //MARK: Get the formatted price of the product up to 2 decimal places for display purpose
    func formatPrice(withInputPrice price: String) -> String {
        return String(format: "%.2f", Double(price)!)
    }
    
    //MARK: Display the formatted price of the attribute value
    func formatAttributeValuePrice(attributePrice price: String) -> String {
        if price.first == "-" {
            return "-$" + price.dropFirst()
        } else {
            return "+$" + price
        }
    }
    
    func initiateLinklyAccessTokenExpiryCheck() {
        if refreshLinklyAccessTokenTimer == nil {
            refreshLinklyAccessTokenTimer = Timer.scheduledTimer(withTimeInterval: 600,
                                                                 repeats: true
            ) { _ in
                Task { [weak self] in
                    if (await self?.refreshToken.checkAndRefreshToken()) != nil {
                        Log.shared.writeToLogFile(atLevel: .info,
                                                  withMessage: "Checking for access token validity as 10 minutes has passed..."
                        )
                    }
                }
            }
        }
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }

    func validatePhoneNumber(phoneNumber: String) -> Bool {
        let phoneNumberRegex = "\\d{10}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberPredicate.evaluate(with: phoneNumber)
    }
}

actor RefreshLinklyToken {
    func checkAndRefreshToken() async {
        guard UserDefaults.linklySecret != nil, UserDefaults.linklyTokenExpiryTime != nil else {
            Log.shared.writeToLogFile(atLevel: .critical,
                                      withMessage: "Either Linkly token or linkly token expiry time is empty. Hence, I'm unable to renew the token automatically."
            )
            
            return
        }
        
        guard UserDefaults.linklyTokenExpiryTime != "" else {
            return
        }
        
        let expiryDateTime = Date().convertStringToDateTime(forDateTime: UserDefaults.linklyTokenExpiryTime!)
        let difference = expiryDateTime.timeIntervalSinceNow
        
        if difference < 300 {
            Task {
                do {
                    async let tokenUpdate = Pairing(isProductionMode: false).getLinklyAuthToken(withSecret: UserDefaults.linklySecret!,
                                                                                                forPOS: "QIKI",
                                                                                                andPOSVersion: appVersionNumber,
                                                                                                andPOSID: deviceUUID,
                                                                                                andPOSVendorID: "QIKI"
                    )
                    
                    let updatedTokenDetails = try await tokenUpdate
                    
                    guard updatedTokenDetails.authToken != "" else {
                        Log.shared.writeToLogFile(atLevel: .info,
                                                  withMessage: "There is an error occurred while updating access token."
                        )
                        
                        UserDefaults.linklySecret = ""
                        UserDefaults.linklyToken = ""
                        UserDefaults.linklyTokenExpiryTime = ""
                        UserDefaults.eftposPaired = false
                        
                        return
                    }
                    
                    UserDefaults.linklyToken = updatedTokenDetails.authToken
                    UserDefaults.linklyTokenExpiryTime = String().convertDateTimeToString(forSelectedDate: Date().calculateAccessTokenExpiryTime(fromSeconds: updatedTokenDetails.tokenExpiryTime))
                    UserDefaults.eftposPaired = true
                    
                    Log.shared.writeToLogFile(atLevel: .info,
                                              withMessage: "New device token is: \(updatedTokenDetails.authToken) and its expiry Date Time is: \(UserDefaults.linklyTokenExpiryTime!) local time."
                    )
                } catch APIError.invalidEndpoint {
                    Log.shared.writeToLogFile(atLevel: .info,
                                              withMessage: "Unable to refresh linkly token because of invalid api end point."
                    )
                } catch APIError.badServerResponse {
                    Log.shared.writeToLogFile(atLevel: .info,
                                              withMessage: "Unable to refresh linkly token because of bad server response received."
                    )
                } catch APIError.networkError {
                    Log.shared.writeToLogFile(atLevel: .info,
                                              withMessage: "Unable to refresh linkly token because of network error."
                    )
                } catch APIError.parsing {
                    Log.shared.writeToLogFile(atLevel: .info,
                                              withMessage: "Unable to refresh linkly token because of parsing error in response."
                    )
                } catch APIError.unknown {
                    Log.shared.writeToLogFile(atLevel: .info,
                                              withMessage: "Unable to refresh linkly token because of unknown error occurred."
                    )
                } catch {
                    Log.shared.writeToLogFile(atLevel: .info,
                                              withMessage: "Unable to refresh linkly token because of unknown error occurred."
                    )
                }
            }
        }
    }
}
