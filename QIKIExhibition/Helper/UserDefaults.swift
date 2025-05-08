//
//  UserDefaults.swift
//  QikiTest
//
//  Created by Miamedia Developer on 14/3/2024.
//

import Foundation

extension UserDefaults {
    public func save<T: Encodable>(customObject object: T, inKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: key)
        }
    }
    
    public func retrieve<T: Decodable>(object type: T.Type, fromKey key: String) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(type, from: data) {
                return object
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    private enum Keys {
        static let accessToken = "accessToken"
        static let rememberLoginDetails = "RememberLoginDetails"
        static let userName = "Username"
        static let password = "Password"
        static let accessTokenExpirySeconds = "AccessTokenExpirySeconds"
        static let accessTokenExpiryTime = "AccessTokenExpiryTime"
        static let isLoggedIn = "isLoggedIn"
        static let deviceTokenString = "deviceToken"
        static let isDeviceTokenRegistered = "false"
        static let isTimerRunning = "true"
        static let storeDetails = "StoreDetails"
        static let appVersion = "appVersion"
        static let baseURL = "baseURL"
        static let lastLogoutDate = "LastLogoutDate"
        static let deviceID = "DeviceID"
        static let merchantId = "MerchantId"
        
        static let isMainTerminal = "isMainTerminal"
        static let shouldApplyDiscount = "ShouldApplyDiscount"
        static let shouldApplyMembership = "ShouldApplyMembership"
        static let shouldAcceptReservation = "ShouldAcceptReservation"
        static let shouldDisplayImage = "ShouldDisplayImage"
        static let isUsingManagerPin = "isUsingManagerPin"
        static let isUsingStaffPin = "isUsingStaffPin"
        
        static let shouldConnectPrinter = "ShouldConnectPrinter"
        static let shouldConnectCashDrawer = "ShouldConnectCashDrawer"
        static let shouldPrintTerminalDockets = "ShouldPrintTerminalDockets"
        static let shouldConnectBarCodeScanner = "ShouldConnectBarcodeScanner"
        static let shouldPrintCategoryName = "ShouldPrintCategoryName"
        static let shouldPrintOrderNo = "ShouldPrintOrderNo"
        static let shouldPrintOrderNoFromKiosk = "ShouldPrintOrderNoFromKiosk"
        
        static let linklyAuthURL = "LinklyAuthURL"
        static let linklyTransactionalURL = "LinklyTransactionalURL"
        static let linklySerialNumber = "LinklySerialNumber"
        static let linklyUsername = "LinklyUsername"
        static let linklyPassword = "LinklyPassword"
        static let linklySecret = "LinklySecret"
        static let linklyToken = "LinklyToken"
        static let linklyTokenExpiryTime = "LinklyTokenExpiryTime"
        static let eftposPaired = "EFTPOSPaired"
        static let linklySessionId = "LinklySessionId"
        
        static let lastActiveOrder = "LastActiveOrder"
        static let isLandscapeLeft = "isLandscapeLeft"
        
        static let lastOrderIdentifier = "LastOrderIdentifier"
        static let userLoggedOutAfterHours = "UserLoggedOutAfterHours"
        static let selectedDocketSections = "SelectedDocketSections"
        
        static let tableLayout = "TableLayout"
        
        static let isWeekendSurchargeOn = "IsWeekendSurchargeOn"
        static let weekendSurcharge = "WeekendSurcharge"
        static let isPublicHolidaySurchargeOn = "IsPublicHolidaySurchargeOn"
        static let publicHolidaySurcharge = "PublicHolidaySurcharge"
    }
    
    // MARK: - Static values
    //Login
    static var accessToken: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.accessToken) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.accessToken)
        }
    }
    
    static var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isLoggedIn)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isLoggedIn)
        }
    }
    
    static var appVersion: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.appVersion) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.appVersion)
        }
    }
    
    static var rememberLoginDetails: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.rememberLoginDetails)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.rememberLoginDetails)
        }
    }
    
    static var userName: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userName)
        }
    }
    
    static var password: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.password) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.password)
        }
    }
    
    static var accessTokenExpirySeconds: Int? {
        get {
            return UserDefaults.standard.integer(forKey: Keys.accessTokenExpirySeconds)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Keys.accessTokenExpirySeconds)
        }
    }
    
    static var accessTokenExpiryTime: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.accessTokenExpiryTime) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.accessTokenExpiryTime)
        }
    }
    
    static var deviceTokenString: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.deviceTokenString) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.deviceTokenString)
        }
    }
    
    static var isDeviceTokenRegistered: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isDeviceTokenRegistered)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isDeviceTokenRegistered)
        }
    }
    
    static var isTimerRunning: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isTimerRunning)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isTimerRunning)
        }
    }
    
    static var isLandscapeLeft: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isLandscapeLeft)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isLandscapeLeft)
        }
    }
    
    static var merchantId: Int? {
        get {
            return UserDefaults.standard.integer(forKey: Keys.merchantId)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.merchantId)
        }
    }
    
    static var lastLogoutDate: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.lastLogoutDate) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastLogoutDate)
        }
    }
    
    static var lastActiveOrder: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.lastActiveOrder)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Keys.lastActiveOrder)
        }
    }
    
    //POS Settings
    static var isMainTerminal: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isMainTerminal)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isMainTerminal)
        }
    }
    
    static var shouldApplyDiscount: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldApplyDiscount)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldApplyDiscount)
        }
    }
    
    static var shouldApplyMembership: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldApplyMembership)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldApplyMembership)
        }
    }
    
    static var shouldAcceptReservation: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldAcceptReservation)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldAcceptReservation)
        }
    }
    
    static var shouldDisplayImage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldDisplayImage)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldDisplayImage)
        }
    }
    
    static var isUsingManagerPin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isUsingManagerPin)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isUsingManagerPin)
        }
    }

    static var isUsingStaffPin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isUsingStaffPin)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isUsingStaffPin)
        }
    }
    
    //Printer Settings
    static var shouldConnectPrinter: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldConnectPrinter)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldConnectPrinter)
        }
    }
    
    static var shouldConnectCashDrawer: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldConnectCashDrawer)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldConnectCashDrawer)
        }
    }
    
    static var shouldPrintTerminalDockets: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldPrintTerminalDockets)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldPrintTerminalDockets)
        }
    }
    
    static var shouldConnectBarCodeScanner: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldConnectBarCodeScanner)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldConnectBarCodeScanner)
        }
    }
    
    static var shouldPrintCategoryName: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldPrintCategoryName)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldPrintCategoryName)
        }
    }
    
    static var shouldPrintOrderNo: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldPrintOrderNo)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldPrintOrderNo)
        }
    }
    
    static var shouldPrintOrderNoFromKiosk: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldPrintOrderNoFromKiosk)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.shouldPrintOrderNoFromKiosk)
        }
    }
    
    static var lastOrderIdentifier: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.lastOrderIdentifier) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastOrderIdentifier)
        }
    }
    
    static var userLoggedOutAfterHours: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.userLoggedOutAfterHours)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userLoggedOutAfterHours)
        }
    }
    
    //EFTPOS Settings
    static var linklyAuthURL: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklyAuthURL) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklyAuthURL)
        }
    }

    static var linklyTransactionalURL: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklyTransactionalURL) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklyTransactionalURL)
        }
    }

    static var linklySerialNumber: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklySerialNumber) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklySerialNumber)
        }
    }
    
    static var linklyUsername: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklyUsername) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklyUsername)
        }
    }

    static var linklyPassword: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklyPassword) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklyPassword)
        }
    }

    static var linklySecret: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklySecret) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklySecret)
        }
    }
    
    static var linklyToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklyToken) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklyToken)
        }
    }

    static var linklyTokenExpiryTime: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklyTokenExpiryTime) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklyTokenExpiryTime)
        }
    }
    
    static var eftposPaired: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.eftposPaired)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.eftposPaired)
        }
    }
    
    static var linklySessionId: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.linklySessionId) ?? ""
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.linklySessionId)
        }

    }

    //Surcharge
    static var isWeekendSurchargeOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isWeekendSurchargeOn)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isWeekendSurchargeOn)
        }
    }
    
    static var weekendSurcharge: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.weekendSurcharge) ?? "0"
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.weekendSurcharge)
        }
    }
    
    static var isPublicHolidaySurchargeOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isPublicHolidaySurchargeOn)
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isPublicHolidaySurchargeOn)
        }
    }
    
    static var publicHolidaySurcharge: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.publicHolidaySurcharge) ?? "0"
        }
        set(newValue) {
            UserDefaults.standard.setValue(newValue, forKey: Keys.publicHolidaySurcharge)
        }
    }

    // MARK:- Static functions
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: Keys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: Keys.isTimerRunning)
        UserDefaults.standard.removeObject(forKey: Keys.storeDetails)
        UserDefaults.standard.removeObject(forKey: Keys.deviceID)
        UserDefaults.standard.removeObject(forKey: Keys.accessToken)
        UserDefaults.standard.synchronize()
    }
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

protocol ObjectSavable {
    func setObject<PrinterData>(_ object: PrinterData, forKey: String) throws where PrinterData: Encodable
    func getObject<PrinterData>(forKey: String, castTo type: PrinterData.Type) throws -> PrinterData where PrinterData: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}
