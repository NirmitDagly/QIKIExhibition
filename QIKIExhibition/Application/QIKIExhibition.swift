//
//  QIKIExhibition.swift
//  QIKIExhibition
//
//  Created by Miamedia on 5/5/2025.
//

import Foundation
import SwiftUI
import Logger
import Network
import DesignSystem
import Router

struct QIKIExhibition: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let configuration: Configuration

    init() {
        Log.shared.initialiseLogger()
        Log.shared.writeToLogFile(atLevel: .info,
                                  withMessage: "App has launched with version: \(Helper.shared.getAppVersionNumber())"
        )
        
        let logger = Logger(label: "Qiki Exhibition App")
        
        do {
            if try DBOperation.shared.checkDatabase() == false {
                try DBOperation.shared.createDatabase()
                CreateTables.shared.createTables()
            } else {
                //Database Migration or Updation here from the future version
            }
        } catch {
            //Error occurred while checking/creating database.
        }
        
        let apiClientService = APIClientService(logger: logger,
                                                configuration: .init(baseURL: URL(string: "https://crm.qiki.com.au"),
                                                                     baseHeaders: ["Accept": "application/json",
                                                                                   "content-type": "application/json"
                                                                                  ]
                                                                    )
        )
        
        configuration = .init(logger: logger,
                              apiClientService: apiClientService
        )
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(configuration)
        }
    }
}

struct SplashView: View {
    
    @State var isActive: Bool = false
    
    let configuration: Configuration
        
    var body: some View {
        ZStack {
            if self.isActive {
                AppTabView()
                    .environmentObject(configuration)
            } else {
                Rectangle()
                    .background(Color.qikiColor)
                
                Image("QikiLogoWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 450,
                           height: 300
                    )
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
}

class Configuration: ObservableObject {
    let logger: Logger
    
    let apiClientService: APIClientService
    
    init(logger: Logger,
         apiClientService: APIClientService
    ) {
        self.logger = logger
        self.apiClientService = apiClientService
    }
}
