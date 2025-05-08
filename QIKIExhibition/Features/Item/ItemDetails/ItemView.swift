//
//  ItemView.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import SwiftUI
import Router
import SwiftUI
import DesignSystem
import Network
import Logger
import SDWebImageSwiftUI
import QAlert

struct ItemView: View {
    
    @State var title = "Catalog"
    
    @StateObject var itemViewModel: ItemViewModel
    
    @EnvironmentObject var configuration: Configuration
    
    @StateObject var router = Router()
    
    init() {
        _itemViewModel = .init(wrappedValue: ItemViewModel())
    }
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            GeometryReader { _ in
                ZStack {
                    VStack(spacing: 0) {
//                        ItemOverviewTitleView(titleText: $title,
//                                              itemViewModel: itemViewModel
//                        )
//                        .padding(.bottom,
//                                 -20
//                        )
                        
                        CategoryView(itemViewModel: itemViewModel,
                                     configuration: configuration,
                                     router: router
                        )
                        
                        Spacer(minLength: 0.5)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ResetView"))) { _ in
                        itemViewModel.resetView()
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            .customAlert("ALERT",
                         isPresented: $itemViewModel.deleteCartAlertConfirmation,
                         showingCancelButton: $itemViewModel.shouldShowCancelButton,
                         actionText: "Ok",
                         actionOnDismiss: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "User tapped on cancel button in alert message. Message: \(itemViewModel.alertMessage)"
                )
            },
                         action: {
                //Delete all added cart items.
                itemViewModel.resetView()
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "\(itemViewModel.alertMessage)"
                )
            },
                         message: {
                Text("\(itemViewModel.alertMessage)")
            }
            )
            .customAlert("ALERT",
                         isPresented: $itemViewModel.displayErrorAlert,
                         showingCancelButton: $itemViewModel.shouldShowCancelButton,
                         actionText: "Ok",
                         actionOnDismiss: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "User tapped on cancel button in alert message. Message: \(itemViewModel.alertMessage)"
                )
            },
                         action: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "\(itemViewModel.alertMessage)"
                )
            },
                         message: {
                Text("\(itemViewModel.alertMessage)")
            }
            )
            .customAlert("ALERT",
                         isPresented: $itemViewModel.displaySuccessAlert,
                         showingCancelButton: $itemViewModel.shouldShowCancelButton,
                         actionText: "Ok",
                         actionOnDismiss: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "User tapped on cancel button in alert message. Message: \(itemViewModel.alertMessage)"
                )
            },
                         action: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "\(itemViewModel.alertMessage)"
                )
            },
                         message: {
                Text("\(itemViewModel.alertMessage)")
            }
            )
            .customAlert("ALERT",
                         isPresented: $itemViewModel.displayNetworkAlert,
                         showingCancelButton: $itemViewModel.shouldShowCancelButton,
                         actionText: "Ok",
                         actionOnDismiss: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "User tapped on cancel button in alert message. Message: \(itemViewModel.alertMessage)"
                )
            },
                         action: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "\(itemViewModel.alertMessage)"
                )
            },
                         message: {
                Text("\(itemViewModel.alertMessage)")
            }
            )
        }
        .environmentObject(router)
    }
}

fileprivate struct ItemOverviewTitleView: View {
    
    @Binding var titleText: String
    
    @ObservedObject var itemViewModel: ItemViewModel
    
    var body: some View {
        HStack() {
            
            Spacer()
            
            Text(titleText)
                .foregroundColor(.white)
                .font(.demiBoldFontWithSize(withSize: 24))
            
            Spacer()
        }
        .frame(height: 64,
               alignment: .center
        )
        .background(Color.qikiColor)
    }
}

fileprivate struct CategoryView: View {
    
    @State var gridItems = [GridItem]()
    
    @ObservedObject var itemViewModel: ItemViewModel
    
    @ObservedObject var configuration: Configuration
    
    @ObservedObject var router: Router
    
    var body: some View {
        if itemViewModel.categories.count > 0 {
            ScrollView(.horizontal,
                       showsIndicators: false
            ) {
                HStack(spacing: 0) {
                    LazyHGrid(rows: gridItems,
                              spacing: 10
                    ) {
                        ForEach(itemViewModel.categories,
                                id: \.id
                        ) { category in
                            Button {
                                
                            } label: {
                                Text(category.name)
                                    .foregroundColor(Color.qikiColor)
                                    .font(.demiBoldFontWithSize(withSize: 18))
                                    .padding([.leading, .trailing],
                                             20
                                    )
                            }
                            .frame(height: 50)
                            .background(Color.white)
                            .padding(.top,
                                     10
                            )
                        }
                    }
                    .onAppear {
                        gridItems = itemViewModel.allocateGridItemsForCategory()
                    }
                }
            }
            .frame(height: 60,
                   alignment: .leading
            )
            .background(Color.qikiColor)
            
            ViewPlacement(itemViewModel: itemViewModel,
                          configuration: configuration,
                          router: router
            )
        }
    }
}

fileprivate struct ViewPlacement: View {

    @ObservedObject var itemViewModel: ItemViewModel
    
    @ObservedObject var configuration: Configuration
    
    @ObservedObject var router: Router

    var body: some View {
        HStack(spacing: 0) {
            
            MenuItemsView(itemViewModel: itemViewModel)
                .padding(.top,
                         30
                )

            Divider()
                .frame(width: 1)
                .foregroundStyle(Color.qikiColor)
            
            DocketView(itemViewModel: itemViewModel,
                       configuration: configuration,
                       router: router
            )
            .frame(width: 300)
        }
    }
}

fileprivate struct MenuItemsView: View {

    @State var gridItems = [GridItem]()
    
    @ObservedObject var itemViewModel: ItemViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            ScrollView() {
                LazyVGrid(columns: gridItems,
                          spacing: 10
                ) {
                    ItemProductView(itemViewModel: itemViewModel)
                }
                .onAppear {
                    gridItems = itemViewModel.allocateGridItemsForProducts()
                }
            }
            .scrollIndicators(.hidden,
                              axes: .vertical
            )
            .frame(alignment: .leading)
        }
    }
}

fileprivate struct ItemProductView: View {

    @ObservedObject var itemViewModel: ItemViewModel
    
    var body: some View {
        ForEach(itemViewModel.product,
                id: \.id
        ) { product in
            Button {
                //Add item to docket
                itemViewModel.addItemToDocket()
            } label: {
                VStack(spacing: 0) {
                    Text(product.name)
                        .frame(width: 140,
                               height: 140,
                               alignment: .center
                        )
                        .font(.mediumFontWithSize(withSize: 16))
                        .foregroundStyle(Color.black)
                        .truncationMode(.tail)
                }
            }
            .frame(width: 140,
                   height: 140,
                   alignment: .center
            )
            .cornerRadius(5,
                          corners: .allCorners
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.init(uiColor: .lightGray),
                            lineWidth: 1
                           )
            )
            .padding([.leading, .trailing],
                     20
            )
        }
    }
}

fileprivate struct DocketView: View {
    
    @ObservedObject var itemViewModel: ItemViewModel
    
    @ObservedObject var configuration: Configuration
    
    @ObservedObject var router: Router
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text("Order")
                        .frame(alignment: .center)
                        .font(.demiBoldFontWithSize(withSize: 24))
                }
                .padding(.top,
                         15
                )
                
                HStack() {
                    if itemViewModel.itemsInDocket.count > 0 {
                        Button {
                            //Reset cart
                            itemViewModel.resetView()
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 25,
                                       height: 25
                                )
                                .foregroundStyle(Color.red)
                        }
                        .frame(width: 25,
                               height: 25
                        )
                    }
                }
                .frame(width: 300)
                .padding(.leading,
                         250
                )
                .padding(.trailing,
                         20
                )
                .padding(.top,
                         15
                )
            }
            
            ItemInCartView(itemViewModel: itemViewModel)
            
            Spacer()
            
            HStack {
                Text("Total Cost:")
                
                Spacer()
                
                Text("$" + itemViewModel.updateDocketTotal())
            }
            .frame(height: 50)
            .font(.demiBoldFontWithSize(withSize: 20))
            .padding([.leading, .trailing],
                     10
            )
            
            Button {
                guard itemViewModel.itemsInDocket.count > 0 else {
                    itemViewModel.alertMessage = "Please add item(s) to order."
                    itemViewModel.shouldShowCancelButton = false
                    itemViewModel.displayErrorAlert = true
                    
                    return
                }
                
                router.navigate(to: CheckoutDestination.checkoutView(itemsInDocket: itemViewModel.itemsInDocket))
            } label: {
                Text("Checkout")
                    .font(.demiBoldFontWithSize(withSize: 20))
                    .frame(width: 300,
                            height: 60,
                            alignment: .center
                    )
                    .foregroundStyle(Color.white)
                    .background(Color.qikiGreen)
            }
            .navigationDestination(for: CheckoutDestination.self) { destination in
                switch destination {
                case .checkoutView(let itemsInDocket):
                    CheckoutView(repository: CheckoutRepository.init(apiClientService: configuration.apiClientService),
                                 andItemsInDocket: itemsInDocket
                    )
                    .navigationBarBackButtonHidden()
                }
            }
        }
    }
}

fileprivate struct ItemInCartView: View {
    
    @ObservedObject var itemViewModel: ItemViewModel
    
    var body: some View {
        VStack {
            if itemViewModel.itemsInDocket.count == 0 {
                Text("NO ITEMS IN DOCKET")
                    .font(.demiBoldFontWithSize(withSize: 20))
                    .foregroundStyle(Color.gray)
                    .padding(.top,
                             40
                    )
                
                Spacer()
            }
            else {
                List {
                    Section {
                        ForEach(itemViewModel.itemsInDocket,
                                id: \.id
                        ) { item in
                            CartItemDetailsView(item: item,
                                                itemViewModel: itemViewModel
                            )
                            .frame(minHeight: 50)
                        }
                                .listRowSeparatorTint(Color.gray)
                    }
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
    }
}

fileprivate struct CartItemDetailsView: View {
    
    var item: Product
    
    @ObservedObject var itemViewModel: ItemViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(item.qty)")
                        Text("x")
                        Text("\(item.name)")
                    }
                    .font(.mediumFontWithSize(withSize: 16))
                    .frame(alignment: .leading)
                }
                
                Spacer()
                
                Text("$\(Calculator.shared.priceInString(withPrice: item.price))")
                    .font(.mediumFontWithSize(withSize: 16))
                    .frame(alignment: .trailing)
            }
        }
        .foregroundStyle(Color.black)
        .buttonStyle(.plain)
    }
}

#Preview {
    ItemView()
}

extension ItemView {
    
    struct Dependencies {
        let apiClient: APIClientService
        
        public init(apiClient: APIClientService) {
            self.apiClient = apiClient
        }
    }
    
}
