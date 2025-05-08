//
//  EnquiriesViewModel.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import Logger
import Network

final class EnquiriesViewModel: ObservableObject {
    
    @Published public var selectedDate = Date()
    
    @Published public var enquiries = [InquiryRecordDetails]()
    
    private let repository: EnquiriesRepository
    
    init(repository: EnquiriesRepository) {
        self.repository = repository
    }
}

extension EnquiriesViewModel {
    
    public func getAllEnquiries() {
        do {
            enquiries = try repository.getAllEnquiries()
        } catch {
            //Error logged at repository level.
        }
    }
}
