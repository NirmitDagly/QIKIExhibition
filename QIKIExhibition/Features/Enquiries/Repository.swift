//
//  Repository.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import GRDB

protocol QEnquiriesRepository {
    func getAllEnquiries() throws -> [InquiryRecordDetails]
    
}

public final class EnquiriesRepository: QEnquiriesRepository {
    
    func getAllEnquiries() throws -> [InquiryRecordDetails] {
        var inquiries = [InquiryRecordDetails]()
        
        do {
            try dbPool!.read { db in
                inquiries = try InquiryRecordDetails.fetchAll(db)
                if inquiries.count > 0 {
                    inquiries = inquiries.sorted(by: {$0.id > $1.id})
                }
            }
        } catch {
            Log.shared.writeToLogFile(atLevel: .error,
                                      withMessage: "Error fetching tax groups from database: \(error)"
            )
        }
        
        return inquiries
    }
    
}
