//
//  ItemCoordinator.swift
//  QIKIExhibition
//
//  Created by Miamedia on 5/5/2025.
//

import SwiftUI
import Router
import SwiftUI
import Network
import Logger

struct ItemCoordinator: View {
    
    @EnvironmentObject var configuration: Configuration
    
    @EnvironmentObject var router: Router
    
    var body: some View {
        ItemView()
    }
}

#Preview {
    ItemCoordinator()
}

extension ItemCoordinator {
    struct Dependencies {
        
        let apiClient: APIClientService
        
        public init(apiClient: APIClientService) {
            self.apiClient = apiClient
        }
    }
}
