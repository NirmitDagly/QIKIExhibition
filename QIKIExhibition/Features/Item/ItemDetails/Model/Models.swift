//
//  Models.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation

public struct Category: Codable, Hashable {
    var id: Int
    var name: String
}

public struct Product: Codable, Hashable {
    var id: Int
    var name: String
    var qty: Int
    var price: Int
}

public struct Position: Codable, Hashable {
    var id: Int
    var name: String
}
