//
//  DrawCoordinator.swift
//  QIKIExhibition
//
//  Created by Miamedia on 12/5/2025.
//

import Foundation
import Router
import SwiftUI
import Network
import Logger

struct DrawCoordinator: View {

    @EnvironmentObject var configuration: Configuration
    
    @EnvironmentObject var router: Router

    var body: some View {
        DrawView(repository: CheckoutRepository(apiClientService: configuration.apiClientService))
    }
}

#Preview {
    EnquiriesCoordinator()
}

extension DrawCoordinator {
    struct Dependencies {
        
        let apiClient: APIClientService
        
        public init(apiClient: APIClientService) {
            self.apiClient = apiClient
        }
    }
}
