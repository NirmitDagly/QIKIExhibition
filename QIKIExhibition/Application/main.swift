//
//  main.swift
//  QIKIExhibition
//
//  Created by Miamedia on 5/5/2025.
//

import Foundation
import SwiftUI

struct EmptyApp: App {
    var body: some Scene {
        WindowGroup {
            
        }
    }
}

if NSClassFromString("XCTestCase") != nil { // Unit Testing
    EmptyApp.main()
} else { // App
    QIKIExhibition.main()
}
