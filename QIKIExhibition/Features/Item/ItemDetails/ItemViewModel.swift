//
//  ItemViewModel.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import Foundation
import SwiftUI
import GRDB

enum ItemsViewState {
    case error
}

final class ItemViewModel: ObservableObject {
    
    @Published public var state: ItemsViewState = .error
    
    @Published public var selectedDate = Date()
    
    @Published public var categories = demoCateogry
    
    @Published public var product = demoProduct
    
    @Published public var itemsInDocket = [Product]()
    
    @Published public var docketTotal = "0.00"
    
    @Published public var canNavigate = false

    @Published public var isPickupOrder = true
    
    @Published public var displayErrorAlert = false
    
    @Published public var displaySuccessAlert = false
    
    @Published public var displayNetworkAlert = false
    
    @Published public var shouldShowCancelButton = false
    
    @Published public var deleteCartAlertConfirmation = false
    
    @Published public var alertMessage = ""

    //MARK: Allocate grid items for category display
    func allocateGridItemsForCategory() -> [GridItem] {
        var allocatedGridItems = [GridItem]()
        allocatedGridItems = Array(repeating: .init(.fixed(50)),
                                   count: 1
        )
        
        return allocatedGridItems
    }
    
    //MARK: Allocate grid items for products displays
    func allocateGridItemsForProducts() -> [GridItem] {
        var allocatedGridItems = [GridItem]()
        allocatedGridItems = Array(repeating: .init(.adaptive(minimum: 140,
                                                              maximum: 180
                                                             ),
                                                    spacing: 30,
                                                    alignment: .leading
        ),
                                   count: 1
        )
        return allocatedGridItems
    }
}

//MARK: Common Methods
extension ItemViewModel {
    
    //MARK: Add item to docket
    public func addItemToDocket() {
        guard itemsInDocket.count < 1 else {
            return
        }
        
        itemsInDocket.append(contentsOf: product)
    }
    
    //MARK: Update docket total every time when an item is added/removed
    public func updateDocketTotal() -> String {
        if itemsInDocket.count > 0 {
            return Calculator.shared.calculateSubTotal(forProductsInCart: itemsInDocket)
        } else {
            return "0.00"
        }
    }

    public func deleteAllCartItems() {
        itemsInDocket = [Product]()
    }
    
    //MARK: Reset view to default values upon completion of payment
    @objc func resetView() {
        itemsInDocket = [Product]()
        docketTotal = "0.00"
    }
}
