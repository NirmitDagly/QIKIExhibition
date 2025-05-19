//
//  GlobalVariables.swift
//  QikiTest
//
//  Created by Miamedia Developer on 14/3/2024.
//

import Foundation
import SwiftUI
import DesignSystem
import Linkly
import Network
import Logger
import GRDB

let appVersion: String = "QIKI Exhibition \(UIApplication.appVersion)"

let appVersionNumber = UIApplication.versionNumber

let appBuildNumber = UIApplication.buildNumber

let databaseVersion = "1.0"

let deviceUUID = UIDevice.current.identifierForVendor!.uuidString.lowercased() as String

var deviceID = 0

let deviceName = UIDevice.current.name

let deviceModel = UIDevice.current.model

let deviceOSVersion = UIDevice.current.systemVersion

var spinnerActive = false

//User Defaults
let userDefaults = UserDefaults.standard

//Database Pool
var dbPool: DatabasePool? = nil

//Access Token Timer
var refreshAccessTokenTimer: Timer?

//Shared Transaction
var sharedTransaction = TransactionInteraction(isProductionMode: true,
                                               andAuthToken: UserDefaults.linklyToken!
)

//Linkly Access Token Timer
var refreshLinklyAccessTokenTimer: Timer?

var demoCateogry = [Category(id: 1,
                         name: "Miscellaneous")]

var demoProduct = [Product(id: 1,
                           name: "Competition Entry",
                           qty: 1,
                           price: 1)]

var positionList = [Position(id: 1,
                             name: "Owner"),
                    Position(id: 2,
                             name: "Co-owner"),
                    Position(id: 3,
                             name: "CEO"),
                    Position(id: 4,
                             name: "COO"),
                    Position(id: 5,
                             name: "CFO"),
                    Position(id: 6,
                             name: "CTO"),
                    Position(id: 7,
                             name: "Director"),
                    Position(id: 8,
                             name: "Executive Director"),
                    Position(id: 9,
                             name: "CA"),
                    Position(id: 10,
                             name: "Accountant"),
                    Position(id: 11,
                             name: "Staff")
]

var syncTimer: Timer?
