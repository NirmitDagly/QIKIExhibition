//
//  EnquiriesCoordinator.swift
//  QIKIExhibition
//
//  Created by Miamedia on 5/5/2025.
//

import SwiftUI
import Router
import SwiftUI
import Network
import Logger

struct EnquiriesCoordinator: View {

    @EnvironmentObject var configuration: Configuration
    
    @EnvironmentObject var router: Router

    var body: some View {
        EnquiriesView(repository: EnquiriesRepository(apiClientService: configuration.apiClientService))
    }
}

#Preview {
    EnquiriesCoordinator()
}

extension EnquiriesCoordinator {
    struct Dependencies {
        
        let apiClient: APIClientService
        
        public init(apiClient: APIClientService) {
            self.apiClient = apiClient
        }
    }
}
