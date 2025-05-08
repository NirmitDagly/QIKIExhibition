//
//  AppTabView.swift
//  QikiTest
//
//  Created by Miamedia Developer on 22/04/24.
//

import Foundation
import UIKit
import Network
import SwiftUI
import DesignSystem
import Router
import Logger

struct AppTabView: View {
    
    @State private var selection = 0
    
    @EnvironmentObject var router: Router
    
    @EnvironmentObject var configuration: Configuration

    var body: some View {
        TabView(selection: $selection) {
            Group {
                ItemCoordinator()
                    .tabItem {
                        Label("Catalog",
                              image: "TakeawayPOS"
                        )
                    }
                    .tag(0)
                
                EnquiriesCoordinator()
                    .tabItem {
                        Label("Leads",
                              systemImage: "list.clipboard"
                        )
                    }
                    .tag(1)
                
                EFTPOSCoordinator()
                    .tabItem {
                        Label("EFTPOS",
                              systemImage: "australiandollarsign.bank.building"
                        )
                    }
                    .tag(2)
            }
            .toolbarBackground(.visible,
                               for: .tabBar
            )
        }
        .onAppear {
            Helper.shared.initiateLinklyAccessTokenExpiryCheck()
        }
        .tint(Color.qikiColor)
        .environment(\.horizontalSizeClass,
                      .compact
        )
    }
}

#Preview {
    AppTabView()
}
