//
//  DrawView.swift
//  QIKIExhibition
//
//  Created by Miamedia on 12/5/2025.
//

import SwiftUI
import Router
import DesignSystem
import Network
import Logger
import QAlert

struct DrawView: View {
    
    @State var titleText = "Checkout"
    
    @State var name = "Nirmit"
    
    @State var businessName = "QIKI"
    
    @State var email = "nirmit@qiki.com.au"
    
    @State var phone = "0414190553"
    
    @State var position = ""
    
    @State var shouldShowConfirmation = false
    
    @StateObject var checkoutViewModel: CheckoutViewModel
    
    @FocusState var focusedField: FocusableField?
    
    @EnvironmentObject var configuration: Configuration
    
    init(repository: CheckoutRepository) {
        _checkoutViewModel = .init(wrappedValue: CheckoutViewModel(repository: repository))
    }
    
    var body: some View {
        ZStack {
            VStack {
                DrawTitleView(title: titleText,
                              checkoutViewModel: checkoutViewModel
                )
                
                Spacer()
                
                ScrollView {
                    CustomerNameView(name: $name,
                                     checkoutViewModel: checkoutViewModel,
                                     focused: $focusedField
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    BusinessNameView(businessName: $businessName,
                                     checkoutViewModel: checkoutViewModel,
                                     focused: $focusedField
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    BusinessEmailView(email: $email,
                                      checkoutViewModel: checkoutViewModel,
                                      focused: $focusedField
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    BusinessPhoneView(phone: $phone,
                                      checkoutViewModel: checkoutViewModel,
                                      focused: $focusedField
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    BusinessPositionView(position: $position,
                                         checkoutViewModel: checkoutViewModel
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    SaveEntryView(name: $name,
                                  businessName: $businessName,
                                  email: $email,
                                  phone: $phone,
                                  position: $position,
                                  shouldShowConfirmation: $shouldShowConfirmation,
                                  checkoutViewModel: checkoutViewModel
                    )
                    .padding(.bottom,
                             30
                    )
                }
                .scrollIndicators(.hidden)
                
                Spacer()
            }
            
            if checkoutViewModel.shouldShowTransactionView == true {
                BackgroundView()
                
                TransactionView(checkoutViewModel: checkoutViewModel)
            }
            
            if shouldShowConfirmation == true {
                BackgroundView()
                
                EntryConfirmationView()
            } else {
                BackgroundView()
                    .hidden()
                
                EntryConfirmationView()
                    .hidden()
            }
        }
        .onChange(of: shouldShowConfirmation) {
            Task {
                //Display an alert to mark off payment.
                await checkoutViewModel.saveLeadDetailsToDatabase()
            }
            
            name = ""
            businessName = ""
            email = ""
            phone = ""
            position = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                shouldShowConfirmation = false
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

fileprivate struct DrawTitleView: View {

    var title: String
    
    @State private var shouldShowOptions = false
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
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
                .padding(.trailing,
                         10
                )
            
            TextField("",
                      text: $name,
                      prompt: Text("Customer Name")
            )
            .padding(.horizontal,
                     20
            )
            .frame(width: 500,
                   height: 50
            )
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
            .padding(.trailing,
                     20
            )
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
                .padding(.trailing,
                         10
                )
            
            TextField("",
                      text: $businessName,
                      prompt: Text("Business Name")
            )
            .padding(.horizontal,
                     20
            )
            .frame(width: 500,
                   height: 50
            )
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
            .padding(.trailing,
                     20
            )
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
                .padding(.trailing,
                         10
                )
            
            TextField("",
                      text: $email,
                      prompt: Text("Business Email")
            )
            .padding(.horizontal,
                     20
            )
            .frame(width: 500,
                   height: 50
            )
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
            .padding(.trailing,
                     20
            )
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
                .padding(.trailing,
                         10
                )
            
            TextField("",
                      text: $phone,
                      prompt: Text("Business Phone")
            )
            .padding(.horizontal,
                     20
            )
            .frame(width: 500,
                   height: 50
            )
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
            .padding(.trailing,
                     20
            )
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
                Text("Position:")
                    .frame(width: 200,
                           height: 50,
                           alignment: .leading
                    )
                    .font(.demiBoldFontWithSize(withSize: 20))
                
                Text(position)
                    .frame(width: geometryReader.size.width - 580,
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
                        isShowingPicker = true
                    }
                    .popover(isPresented: $isShowingPicker) {
                        Picker("",
                               selection: $position
                        ) {
                            ForEach(checkoutViewModel.positionList,
                                    id: \.self
                            ) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .onChange(of: position) {
                            isShowingPicker = false
                            checkoutViewModel.position = position
                        }
                    }
                    .padding(.trailing,
                             20
                    )
            }
            .frame(width: geometryReader.size.width)
        }
    }
}

fileprivate struct SaveEntryView: View {
    
    @Binding var name: String
    
    @Binding var businessName: String
    
    @Binding var email: String
    
    @Binding var phone: String
    
    @Binding var position: String
    
    @Binding var shouldShowConfirmation: Bool
    
    @ObservedObject var checkoutViewModel: CheckoutViewModel
    
    var body: some View {
        Button {
            //Pay by button clicked...
            guard name != "",
                  businessName != "",
                  email != "",
                  phone != "",
                  position != ""
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
            checkoutViewModel.position = position
            
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "User is entering the following lead details: \nName: \(name), \nBusiness Name: \(businessName), \nBusiness Email: \(email), \nBusiness Phone: \(phone), \nPosition: \(position)."
            )
            
            shouldShowConfirmation = true
        } label: {
            Text("Enter to draw")
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

#Preview {
    DrawView(repository: CheckoutRepository.init(apiClientService: APIClientService(logger: Logger.init(label: ""))))
}
