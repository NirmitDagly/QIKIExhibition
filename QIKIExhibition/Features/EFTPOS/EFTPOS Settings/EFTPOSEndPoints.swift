//
//  EFTPOSEndPoints.swift
//  QikiTest
//
//  Created by Miamedia Developer on 22/04/24.
//

import Foundation
import Network

enum APIEndpoints {
    static func getLinklyCredentials(forSerialNumber serialNumber: String) -> APIEndpoint {
        return .init(
            path: "/getLinklyCredentials",
            httpMethod: .get,
            headers: [
                "deviceUUID": deviceUUID,
                "apiKey": UserDefaults.accessToken
            ],
            bodyParameter: .dictionary(["serialNumber": serialNumber],
                                       options: .prettyPrinted
                                      )
        )
    }
    
    static func saveEFTPOSSettings() -> APIEndpoint {
        return .init(
            path: "/saveEFTPOSSettings",
            httpMethod: .post,
            headers: [
                "deviceUUID": deviceUUID,
                "apiKey": UserDefaults.accessToken
            ]
        )
    }
}
