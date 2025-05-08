//
//  PinpadStatus.swift
//  QikiTest
//
//  Created by Miamedia Developer on 10/10/24.
//

import Foundation
import Network

public struct TerminalStatus: Codable {
    public var sessionID: String?
    public var responseType: String
    public var response: TerminalStatusDetails
}

// MARK: - Terminal Status Details
public struct TerminalStatusDetails: Codable {
    let merchant: String
    let nii: Int
    let catid, caid: String
    let timeout: Int
    let loggedOn: Bool
    let pinPadSerialNumber, pinPadVersion, bankCode, bankDescription: String
    let kvc: String
    let safCount: Int
    let networkType, hardwareSerial, retailerName: String
    let optionsFlags: [String: Bool]
    let safCreditLimit, safDebitLimit, maxSAF: Int
    let keyHandlingScheme: String
    let cashoutLimit, refundLimit: Int
    let cpatVersion, nameTableVersion, terminalCommsType: String
    let cardMisreadCount, totalMemoryInTerminal, freeMemoryInTerminal: Int
    let eftTerminalType: String
    let numAppsInTerminal, numLinesOnDisplay: Int
    let hardwareInceptionDate: String
    let success: Bool
    let responseCode, responseText: String
}
