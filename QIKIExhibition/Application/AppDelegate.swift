//
//  AppDelegate.swift
//  QIKIExhibition
//
//  Created by Miamedia on 5/5/2025.
//

import Foundation
import UIKit
import UserNotifications
import Network

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("App Launched...")
        return true
    }
}
