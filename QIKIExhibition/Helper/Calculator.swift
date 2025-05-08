//
//  Calculator.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import Network
import Logger

public struct Calculator {
    
    static let shared = Calculator()
    
    //MARK: Convert Double to String
    public func doubleToString(withDouble double: Double) -> String {
        return String(format: "%.2f", double)
    }

    //MARK: Convert price from Int to String
    public func priceInString(withPrice price: Int) -> String {
        return String(format: "%.2f", Double(price) / 100)
    }

    //MARK: Convert price from String to Int
    public func priceInInt(withPrice price: String) -> Int {
        guard price != "" else {
            return 0
        }
        
        return Int(price.replacingOccurrences(of: ".", with: ""))!
    }

    //MARK: Product price calculations
    public func calculateSubTotal(forProductsInCart products: [Product]) -> String {
        var subTotal = 0
        
        for i in 0 ..< products.count {
            subTotal = subTotal + products[i].price
        }
        
        return String(format: "%.2f", Double(subTotal) / 100)
    }
}
