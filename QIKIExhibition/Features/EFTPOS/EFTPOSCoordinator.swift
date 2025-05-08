//
//  EFTPOSCoordinator.swift
//  QIKIExhibition
//
//  Created by Miamedia on 5/5/2025.
//

import SwiftUI
import Router
import SwiftUI
import Network
import Logger

struct EFTPOSCoordinator: View {
    
    @EnvironmentObject var configuration: Configuration
    
    @EnvironmentObject var router: Router

    var body: some View {
        EFTPOSSettingsView(repository: EFTPOSRepository.init(apiClientService: configuration.apiClientService),
                           andViewTitle: "EFTPOS"
        )
        .navigationBarBackButtonHidden()
            
    }
}

#Preview {
    EFTPOSCoordinator()
}

extension EFTPOSCoordinator {
    struct Dependencies {
        
        let apiClient: APIClientService
        
        public init(apiClient: APIClientService) {
            self.apiClient = apiClient
        }
    }
}
