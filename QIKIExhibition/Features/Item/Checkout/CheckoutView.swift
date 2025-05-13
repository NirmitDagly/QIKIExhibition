//
//  CheckoutView.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import SwiftUI
import Router
import DesignSystem
import Network
import Logger
import QAlert

struct CheckoutView: View {
    
    @State var titleText = "Checkout"
    
    @State var name = "Nirmit"
    
    @State var businessName = "QIKI"
    
    @State var email = "nirmit@qiki.com.au"
    
    @State var phone = "0414190553"
    
    @State var position = ""
    
    @State var shouldShowConfirmation = false
    
    @StateObject var checkoutViewModel: CheckoutViewModel
    
    @FocusState var focusedField: FocusableField?
    
    @EnvironmentObject var router: Router
    
    @EnvironmentObject var configuration: Configuration
    
    var itemsInDocket = [Product]()
    
    init(repository: CheckoutRepository,
         andItemsInDocket itemsInDocket: [Product]
    ) {
        _checkoutViewModel = .init(wrappedValue: CheckoutViewModel(repository: repository))
        self.itemsInDocket = itemsInDocket
    }
    
    var body: some View {
        GeometryReader { geometryReader in
            ZStack {
                VStack {
                    CheckoutTitleView(title: titleText,
                                      checkoutViewModel: checkoutViewModel,
                                      router: router
                    )
                    
                    HStack(spacing: 0) {
                        DocketView(checkoutViewModel: checkoutViewModel,
                                   router: router
                        )
                        .frame(width: 300)
                        
                        Divider()
                            .foregroundStyle(Color.gray)
                        
                        Spacer()
                        
                        VStack {
                            ScrollView {
                                AmountView(checkoutViewModel: checkoutViewModel)
                                    .padding([.top, .bottom],
                                             20
                                    )
                                
                                CustomerNameView(name: $name,
                                                 checkoutViewModel: checkoutViewModel,
                                                 focused: $focusedField
                                )
                                .padding(.bottom,
                                         10
                                )
                                
                                BusinessNameView(businessName: $businessName,
                                                 checkoutViewModel: checkoutViewModel,
                                                 focused: $focusedField
                                )
                                .padding(.bottom,
                                         10
                                )
                                
                                BusinessEmailView(email: $email,
                                                  checkoutViewModel: checkoutViewModel,
                                                  focused: $focusedField
                                )
                                .padding(.bottom,
                                         10
                                )
                                
                                BusinessPhoneView(phone: $phone,
                                                  checkoutViewModel: checkoutViewModel,
                                                  focused: $focusedField
                                )
                                .padding(.bottom,
                                         10
                                )
                                
                                BusinessPositionView(position: $position,
                                                     checkoutViewModel: checkoutViewModel
                                )
                                .frame(height: 50)
                                .padding(.bottom,
                                         10
                                )
                                
                                PaybyView(checkoutViewModel: checkoutViewModel)
                                    .frame(width: abs(geometryReader.size.width - 300),
                                           height: 50
                                    )
                                    .padding(.bottom,
                                             30
                                    )
                                
                                PayNowView(name: $name,
                                           businessName: $businessName,
                                           email: $email,
                                           phone: $phone,
                                           position: $position,
                                           shouldShowConfirmation: $shouldShowConfirmation,
                                           checkoutViewModel: checkoutViewModel,
                                           router: router
                                )
                                .padding(.bottom,
                                         30
                                )
                                
                                Spacer()
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                }
                .frame(width: geometryReader.size.width)
                .onAppear() {
                    checkoutViewModel.itemsInDocket = itemsInDocket
                    checkoutViewModel.finalPayableAmount()
                }
                
                if checkoutViewModel.shouldShowTransactionView == true {
                    BackgroundView()
               
                    TransactionView(checkoutViewModel: checkoutViewModel)
                }
                
                if checkoutViewModel.shouldShowPositionList {
                    BackgroundView()
                    
                    PositionListView(checkoutViewModel: checkoutViewModel)
                } else {
                    BackgroundView()
                        .hidden()
                    
                    PositionListView(checkoutViewModel: checkoutViewModel)
                        .hidden()
                }
                
                if shouldShowConfirmation == true {
                    BackgroundView()
                    
                    EntryConfirmationView()
                }
            }
            .onChange(of: shouldShowConfirmation) {
                Task {
                    //Display an alert to mark off payment.
                    await checkoutViewModel.saveLeadDetailsToDatabase()
                }

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ResetView"),
                                                object: nil
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    router.navigateBack()
                }
            }
            .customAlert("ALERT",
                         isPresented: $checkoutViewModel.displayErrorAlert,
                         showingCancelButton: $checkoutViewModel.shouldShowCancelButton,
                         actionText: "Ok",
                         actionOnDismiss: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "User tapped on cancel button in alert message. Message: \(checkoutViewModel.alertMessage)"
                )
            },
                         action: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "\(checkoutViewModel.alertMessage)"
                )
            },
                         message: {
                Text("\(checkoutViewModel.alertMessage)")
            }
            )
            .customAlert("ALERT",
                         isPresented: $checkoutViewModel.displaySuccessAlert,
                         showingCancelButton: $checkoutViewModel.shouldShowCancelButton,
                         actionText: "Ok",
                         actionOnDismiss: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "User tapped on cancel button in alert message. Message: \(checkoutViewModel.alertMessage)"
                )
            },
                         action: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "\(checkoutViewModel.alertMessage)"
                )
            },
                         message: {
                Text("\(checkoutViewModel.alertMessage)")
            }
            )
            .customAlert("ALERT",
                         isPresented: $checkoutViewModel.displayNetworkAlert,
                         showingCancelButton: $checkoutViewModel.shouldShowCancelButton,
                         actionText: "Ok",
                         actionOnDismiss: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "User tapped on cancel button in alert message. Message: \(checkoutViewModel.alertMessage)"
                )
            },
                         action: {
                Log.shared.writeToLogFile(atLevel: .info,
                                          withMessage: "\(checkoutViewModel.alertMessage)"
                )
            },
                         message: {
                Text("\(checkoutViewModel.alertMessage)")
            }
            )
        }
    }
}

fileprivate struct CheckoutTitleView: View {

    var title: String
    
    @State private var shouldShowOptions = false
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    @ObservedObject var router: Router
    
    var body: some View {
        HStack() {
            
            Spacer()
            
            Text(title)
                .frame(alignment: .center)
                .font(.demiBoldFontWithSize(withSize: 24))
                .foregroundColor(.white)
                .padding(.leading,
                         20
                )
            
            Spacer()
        }
        .frame(height: 64,
               alignment: .center
        )
        .background(Color.qikiColor)
    }
}

fileprivate struct DocketView: View {
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    @ObservedObject var router: Router
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(checkoutViewModel.itemsInDocket,
                            id: \.id
                    ) { item in
                        HStack {
                            HStack {
                                Group {
                                    Text("\(item.qty)")
                                    Text("x")
                                    Text("\(item.name)")
                                }
                                .font(.mediumFontWithSize(withSize: 16))
                                .frame(alignment: .leading)
                                .foregroundStyle(Color.black)
                                .padding(.leading,
                                         10
                                )
                            }
                            
                            Spacer()
                            
                            Text("$\(Calculator.shared.priceInString(withPrice: item.price))")
                                .font(.mediumFontWithSize(withSize: 16))
                                .frame(alignment: .trailing)
                                .foregroundStyle(Color.black)
                                .padding(.trailing,
                                         10
                                )
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            
            HStack {
                Text("Sub Total:")
                
                Spacer()
                
                Text("$\(checkoutViewModel.transactionAmount)")
            }
            .font(.demiBoldFontWithSize(withSize: 18))
            .padding([.leading, .trailing],
                     10
            )
            .padding(.bottom,
                     5
            )
                
            HStack {
                Text("Total:\n(inclusive of GST)")
                
                Spacer()
            
                Text("$\(checkoutViewModel.transactionAmount)")
            }
            .font(.demiBoldFontWithSize(withSize: 18))
            .padding([.leading, .trailing],
                     10
            )
            .padding(.bottom,
                     5
            )
            
            Button {
                router.navigateBack()
            } label: {
                Text("Edit Order")
            }
            .frame(width: 300,
                   height: 60
            )
            .font(.demiBoldFontWithSize(withSize: 24))
            .foregroundStyle(Color.white)
            .background(Color.qikiColor)
        }
        .frame(width: 300)
        .ignoresSafeArea(.keyboard)
    }
}

fileprivate struct AmountView: View {
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        HStack {
            Spacer()
            
            Text("Total Order Amount: $\(checkoutViewModel.transactionAmount)")
                .frame(height: 50)
                .font(.mediumFontWithSize(withSize: 24))
                .foregroundStyle(Color.black)
            
            Spacer()
        }
    }
}

fileprivate struct CustomerNameView: View {
    
    @Binding var name: String
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var focused: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Text("Customer Name:")
                .frame(width: 200,
                       height: 50,
                       alignment: .leading
                )
                .font(.demiBoldFontWithSize(withSize: 20))
                .padding(.leading,
                         20
                )
            
            Spacer()
            
            TextField("",
                      text: $name,
                      prompt: Text("Customer Name")
            )
            .padding(.horizontal,
                     20
            )
            .frame(height: 50)
            .font(.mediumFontWithSize(withSize: 16))
            .cornerRadius(10,
                          corners: .allCorners
            )
            .border(Color.gray)
            .submitLabel(.next)
            .onSubmit {
                guard name != "" else {
                    //Display alert here
                    return
                }
                
                checkoutViewModel.name = name
                focused.wrappedValue = FocusableField.businessName
            }
            .padding([.leading, .trailing],
                     20
            )
            
            Spacer()
        }
    }
}

fileprivate struct BusinessNameView: View {
    
    @Binding var businessName: String
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var focused: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Text("Business Name:")
                .frame(width: 200,
                       height: 50,
                       alignment: .leading
                )
                .font(.demiBoldFontWithSize(withSize: 20))
                .padding(.leading,
                         20
                )
            
            Spacer()
            
            TextField("",
                      text: $businessName,
                      prompt: Text("Business Name")
            )
            .padding(.horizontal,
                     20
            )
            .frame(height: 50)
            .font(.mediumFontWithSize(withSize: 16))
            .focused(focused,
                     equals: .businessName
            )
            .cornerRadius(10,
                          corners: .allCorners
            )
            .border(Color.gray)
            .submitLabel(.next)
            .onSubmit {
                guard businessName != "" else {
                    //Display alert here
                    return
                }
                
                checkoutViewModel.businessName = businessName
                focused.wrappedValue = .businessEmail
            }
            .padding([.leading, .trailing],
                     20
            )
            
            Spacer()
        }
    }
}

fileprivate struct BusinessEmailView: View {
    
    @Binding var email: String
        
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var focused: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Text("Business Email:")
                .frame(width: 200,
                       height: 50,
                       alignment: .leading
                )
                .font(.demiBoldFontWithSize(withSize: 20))
                .padding(.leading,
                         20
                )
            
            Spacer()
            
            TextField("",
                      text: $email,
                      prompt: Text("Business Email")
            )
            .padding(.horizontal,
                     20
            )
            .frame(height: 50)
            .font(.mediumFontWithSize(withSize: 16))
            .keyboardType(.emailAddress)
            .focused(focused,
                     equals: .businessEmail
            )
            .cornerRadius(10,
                          corners: .allCorners
            )
            .border(Color.gray)
            .submitLabel(.next)
            .onSubmit {
                guard email != "" else {
                    //Display alert here
                    return
                }
                
                checkoutViewModel.businessEmail = email
                focused.wrappedValue = .businessPhone
            }
            .padding([.leading, .trailing],
                     20
            )
            
            Spacer()
        }
    }
}

fileprivate struct BusinessPhoneView: View {
    
    @Binding var phone: String
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var focused: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Text("Business Phone:")
                .frame(width: 200,
                       height: 50,
                       alignment: .leading
                )
                .font(.demiBoldFontWithSize(withSize: 20))
                .padding(.leading,
                         20
                )
            
            Spacer()
            
            TextField("",
                      text: $phone,
                      prompt: Text("Business Phone")
            )
            .padding(.horizontal,
                     20
            )
            .frame(height: 50)
            .font(.mediumFontWithSize(withSize: 16))
            .keyboardType(.numberPad)
            .focused(focused,
                     equals: .businessPhone
            )
            .cornerRadius(10,
                          corners: .allCorners
            )
            .border(Color.gray)
            .submitLabel(.done)
            .onSubmit {
                guard phone != "" else {
                    //Display alert here
                    return
                }
                
                checkoutViewModel.businessPhone = phone
            }
            .padding([.leading, .trailing],
                     20
            )
            
            Spacer()
        }
    }
}

fileprivate struct BusinessPositionView: View {
    
    @State var isShowingPicker = false
    
    @Binding var position: String
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            HStack {
                Text("Position at Business:")
                    .frame(width: 200,
                           height: 50,
                           alignment: .leading
                    )
                    .font(.demiBoldFontWithSize(withSize: 20))
                    .padding(.leading,
                             20
                    )
                
                Text(checkoutViewModel.position)
                    .frame(width: abs(geometryReader.size.width - 315),
                           height: 50,
                           alignment: .leading
                    )
                    .font(.mediumFontWithSize(withSize: 16))
                    .padding(.horizontal,
                             20
                    )
                    .cornerRadius(10,
                                  corners: .allCorners
                    )
                    .border(Color.gray)
                    .onTapGesture {
                        checkoutViewModel.shouldShowPositionList = true
                        //isShowingPicker = true
                    }
//                    .popover(isPresented: $isShowingPicker) {
//                        Picker("",
//                               selection: $position
//                        ) {
//                            ForEach(checkoutViewModel.positionList,
//                                    id: \.self
//                            ) {
//                                Text($0)
//                            }
//                        }
//                        .pickerStyle(.wheel)
//                        .labelsHidden()
//                        .onChange(of: position) {
//                            isShowingPicker = false
//                            checkoutViewModel.position = position
//                        }
//                    }
                    .padding([.leading, .trailing],
                             20
                    )
                
                Spacer()
            }
        }
    }
}

fileprivate struct PaybyView: View {
    
    @State var selectedPaymentMethod = 0
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            HStack {
                Text("Payment Method: ")
                    .frame(width: 200,
                           height: 50,
                           alignment: .leading
                    )
                    .font(.demiBoldFontWithSize(withSize: 20))
                    .padding(.leading,
                             20
                    )
                
                Spacer()
                
                Picker("",
                       selection: $selectedPaymentMethod
                ) {
                    Text(PaymentMethod.card.rawValue)
                        .tag(0)
                    
                    Text(PaymentMethod.cash.rawValue)
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .colorMultiply(Color.qikiLightGray)
                .frame(width: abs(geometryReader.size.width - 250),
                       height: 50,
                       alignment: .leading
                )
                .scaledToFit()
                .padding(.trailing,
                         20
                )
                .onChange(of: selectedPaymentMethod) {
                    checkoutViewModel.updatePaymentMethodOnSelection(paymentMethod: selectedPaymentMethod)
                }
            }
        }
    }
}

fileprivate struct PayNowView: View {
    
    @Binding var name: String
    
    @Binding var businessName: String
    
    @Binding var email: String
    
    @Binding var phone: String
    
    @Binding var position: String
    
    @Binding var shouldShowConfirmation: Bool
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    @ObservedObject var router: Router
    
    var body: some View {
        Button {
            //Pay by button clicked...
            guard name != "",
                  businessName != "",
                  email != "",
                  phone != "",
                  checkoutViewModel.position != ""
            else {
                checkoutViewModel.alertMessage = "One of the following field is empty:\nName\nBusiness Name\nBusiness Email\nBusiness Phone\nPosition at business."
                checkoutViewModel.shouldShowCancelButton = false
                checkoutViewModel.displayErrorAlert = true
                
                return
            }
            
            checkoutViewModel.name = name
            checkoutViewModel.businessName = businessName
            checkoutViewModel.businessEmail = email
            checkoutViewModel.businessPhone = phone
            
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "User is entering the following lead details: \nName: \(name), \nBusiness Name: \(businessName), \nBusiness Email: \(email), \nBusiness Phone: \(phone), \nPosition: \(position)."
            )
            
            if checkoutViewModel.selectedPaymentMethod == .card {
                if UserDefaults.linklyToken == "" {
                    Log.shared.writeToLogFile(atLevel: .error,
                                              withMessage: "It seems that Linkly Token has expired or EFTPOS got unpaired. Advised user to try again or check pinpad pairing status..."
                    )
                    
                    checkoutViewModel.alertMessage = "It seems that either EFTPOS is not connected or token expired. \n\nPlease check the EFTPOS terminal pairing from \nSettings -> EFTPOS Settings -> Check Pinpad Status."
                    checkoutViewModel.shouldShowCancelButton = false
                    checkoutViewModel.displayErrorAlert = true
                } else {
                    if isNetworkReachable() {
                        checkoutViewModel.shouldShowTransactionView = true
                    } else {
                        checkoutViewModel.networkAlertMessage()
                    }
                }
            } else {
                shouldShowConfirmation = true
            }
        } label: {
            Text("\(checkoutViewModel.payButtonTitle)")
                .frame(width: 300,
                       height: 50
                )
                .font(.demiBoldFontWithSize(withSize: 24))
                .foregroundStyle(Color.white)
                .background(Color.qikiColor)
        }
        .frame(width: 300,
               height: 50
        )
        .cornerRadius(7,
                      corners: .allCorners
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.qikiColor,
                        lineWidth: 2
                       )
        )
    }
}

fileprivate struct EntryConfirmationView: View {
    
    var body: some View {
        GeometryReader { geometryReader in
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
                
                Text("Qiki Competition Entry Confirmed!")
                    .frame(alignment: .center)
                    .font(.demiBoldFontWithSize(withSize: 22))
                    .padding(.bottom,
                             20
                    )
                    .padding([.leading, .trailing],
                             20
                    )
                
                Text("You will receive an email confirming your entry shortly.")
                    .frame(alignment: .center)
                    .font(.demiBoldFontWithSize(withSize: 18))
                    .padding(.bottom,
                             10
                    )
                    .padding([.leading, .trailing],
                             20
                    )
                
                Text("Good luck!")
                    .frame(alignment: .center)
                    .font(.demiBoldFontWithSize(withSize: 18))
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
}

fileprivate struct PositionListView: View {
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                HStack {
                    Button {
                        checkoutViewModel.position = ""
                        checkoutViewModel.shouldShowPositionList = false
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 30,
                                   height: 30
                            )
                            .padding(.leading,
                                     20
                            )
                    }
                    
                    Spacer()
                    
                    Text("Choose Position")
                        .frame(height: 50,
                               alignment: .center
                        )
                        .font(.demiBoldFontWithSize(withSize: 18))
                        .padding(.bottom,
                                 20
                        )
                    
                    Spacer()
                }
                
                List {
                    Section {
                        ForEach(positionList,
                                id: \.id
                        ) { position in
                            HStack {
                                Button {
                                    //Select position
                                    checkoutViewModel.position = position.name
                                    checkoutViewModel.shouldShowPositionList = false
                                } label: {
                                    Text(position.name)
                                        .frame(height: 50)
                                        .font(.mediumFontWithSize(withSize: 18))
                                        .foregroundStyle(Color.qikiColor)
                                }
                                .frame(height: 50)
                                
                                Spacer()
                                
                                if checkoutViewModel.position == position.name {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .frame(width: 25,
                                               height: 25
                                        )
                                        .foregroundStyle(Color.qikiColor)
                                        .padding(.trailing,
                                                 20
                                        )
                                }
                            }
                        }
                        .listRowSeparatorTint(Color.gray)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .frame(width: geometryReader.size.width / 2
            )
            .background(Color.white)
            .padding([.leading, .trailing],
                     geometryReader.size.width / 4
            )
            .padding([.top, .bottom],
                     100
            )
            .cornerRadius(10,
                          corners: .allCorners
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.init(uiColor: .clear),
                            lineWidth: 1
                           )
            )
        }
    }
}

#Preview {
    CheckoutView(repository: CheckoutRepository.init(apiClientService: APIClientService(logger: Logger.init(label: ""))),
                 andItemsInDocket: [Product]()
    )
}
