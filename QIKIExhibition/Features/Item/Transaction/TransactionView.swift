//
//  TransactionView.swift
//  QikiTest
//
//  Created by Miamedia Developer on 22/08/24.
//

import SwiftUI
import Router
import SwiftUI
import DesignSystem
import Network
import Logger

struct TransactionView: View {
    
    @StateObject var transactionViewModel: TransactionViewModel
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel

    @EnvironmentObject var router: Router

    @EnvironmentObject var configuration: Configuration
    
    init(checkoutViewModel: CheckoutViewModel) {
        _transactionViewModel = .init(wrappedValue: TransactionViewModel(withCheckoutViewModel: checkoutViewModel)
        )
        self.checkoutViewModel = checkoutViewModel
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometryReader in
                VStack {
                    TransactionTitleView(transactionViewModel: transactionViewModel,
                                         checkoutViewModel: checkoutViewModel
                    )
                    .padding(.top,
                             20
                    )
                    
                    Spacer()
                    
                    TransactionProgressView(checkoutViewModel: checkoutViewModel,
                                            transactionViewModel: transactionViewModel,
                                            router: router
                    )
                    
                    Spacer()
                    
                    if transactionViewModel.shouldShowCancelButton == true {
                        CancelTransactionView(transactionViewModel: transactionViewModel,
                                              checkoutViewModel: checkoutViewModel,
                                              router: router
                        )
                        .padding(.bottom,
                                 20
                        )
                    }
                }
                .frame(height: 350)
                .background(Color.white)
                .cornerRadius(7,
                              corners: .allCorners
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.clear,
                                lineWidth: 2
                               )
                )
                .padding([.leading, .trailing],
                         geometryReader.size.width / 4
                )
                .padding([.top, .bottom],
                         geometryReader.size.height / 4
                )
                .ignoresSafeArea(.keyboard,
                                 edges: .bottom
                )
            }
        }
        .onAppear() {
            transactionViewModel.transactionAmount = checkoutViewModel.transactionAmount
            Task {
                try await transactionViewModel.initiatePaymentWithLinkly()
            }
        }
        .onChange(of: transactionViewModel.shouldNavigateBack) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                checkoutViewModel.shouldShowTransactionView = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ResetView"),
                                                object: nil
                )
                router.navigateBack()
            }
        }
        .onChange(of: transactionViewModel.state) {
            if transactionViewModel.state == .transactionCancelled || transactionViewModel.state == .error {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    checkoutViewModel.shouldShowTransactionView = false
                }
            }
        }
    }
}

fileprivate struct TransactionTitleView: View {
    
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel

    var body: some View {
        HStack {
//            Button {
//                //xmark button clicked...
//                checkoutViewModel.shouldShowTransactionView = false
//            } label: {
//                Image(systemName: "xmark")
//                    .resizable()
//                    .frame(width: 30,
//                           height: 30,
//                           alignment: .center
//                    )
//                    .foregroundStyle(Color.qikiColor)
//            }
//            .frame(width: 30,
//                   height: 30,
//                   alignment: .center
//            )
//            .padding(.leading,
//                     20
//            )
            
            Spacer()
            
            Text("Pay By Card")
                .frame(height: 30,
                       alignment: .center
                )
                .font(.demiBoldFontWithSize(withSize: 24))
                .padding(.trailing,
                         30
                )
            
            Spacer()
        }
    }
}

fileprivate struct TransactionProgressView: View {
    @ObservedObject var checkoutViewModel: CheckoutViewModel

    @ObservedObject var transactionViewModel: TransactionViewModel

    @ObservedObject var router: Router
    
    var body: some View {
        if transactionViewModel.state == .transactionCompleted {
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 60,
                           height: 60,
                           alignment: .center
                    )
                    .foregroundStyle(Color.qikiGreen)
                    .padding(.bottom,
                             10
                    )
                
                Text("Transaction Successful")
                    .frame(height: 50,
                           alignment: .center
                    )
                    .font(.demiBoldFontWithSize(withSize: 22))
            }
        } else if transactionViewModel.state == .transactionCancelled {
            VStack {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 60,
                           height: 60,
                           alignment: .center
                    )
                    .foregroundStyle(Color.qikiRed)
                    .padding(.bottom,
                             10
                    )
                
                Text("Transaction Cancelled Successfully...")
                    .frame(height: 50,
                           alignment: .center
                    )
                    .font(.demiBoldFontWithSize(withSize: 22))
            }
        } else if transactionViewModel.state == .transactionFailed {
            VStack {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 60,
                           height: 60,
                           alignment: .center
                    )
                    .foregroundStyle(Color.qikiRed)
                    .padding(.bottom,
                             10
                    )
                
                Text("Transaction Failed. Try Again!")
                    .frame(height: 50,
                           alignment: .center
                    )
                    .font(.demiBoldFontWithSize(withSize: 22))
            }
        } else if transactionViewModel.state == .error {
            VStack {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 60,
                           height: 60,
                           alignment: .center
                    )
                    .foregroundStyle(Color.qikiRed)
                    .padding(.bottom,
                             10
                    )
                
                Text("Transaction Failed. Try Again!")
                    .frame(height: 50,
                           alignment: .center
                    )
                    .font(.demiBoldFontWithSize(withSize: 22))
            }
        } else {
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.large)
                    .padding(.bottom,
                             10
                    )

                Text(transactionViewModel.displayMessageOnIndicator())
                    .frame(height: 50,
                           alignment: .center
                    )
                    .font(.demiBoldFontWithSize(withSize: 22))
            }
        }
    }
}

fileprivate struct CancelTransactionView: View {
    
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    @ObservedObject var router: Router
    
    var body: some View {
        Button {
            Task {
                try await transactionViewModel.cancelPaymentWithLinkly()
            }
        } label: {
            Text("Cancel Transaction")
                .frame(width: 300,
                       height: 50
                )
                .font(.demiBoldFontWithSize(withSize: 24))
                .foregroundStyle(Color.white)
                .background(Color.qikiRed)
        }
        .frame(width: 300,
               height: 50
        )
        .cornerRadius(7,
                      corners: .allCorners
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.clear,
                        lineWidth: 2
                       )
        )
    }
}

#Preview {
    TransactionView(checkoutViewModel: CheckoutViewModel(repository: CheckoutRepository.init(apiClientService: APIClientService(logger: Logger.init(label: "")))))
}
