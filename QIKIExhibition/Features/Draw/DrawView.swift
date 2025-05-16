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
    
    @State var titleText = "Draw Entry Form"
    
    @State var name = ""
        
    @State var businessName = ""
    
    @State var email = ""
    
    @State var phone = ""
    
    @State var position = ""
    
    @State var shouldShowConfirmation = false
    
    @StateObject var drawViewModel: DrawViewModel
    
    @FocusState var focusedField: FocusableField?
    
    @EnvironmentObject var configuration: Configuration
    
    init(repository: DrawRepository) {
        _drawViewModel = .init(wrappedValue: DrawViewModel(repository: repository))
    }
    
    var body: some View {
        ZStack {
            VStack {
                DrawTitleView(title: titleText,
                              drawViewModel: drawViewModel
                )
                
                Spacer()
                
                ScrollView {
                    CustomerNameView(name: $name,
                                     drawViewModel: drawViewModel,
                                     focused: $focusedField
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    BusinessNameView(businessName: $businessName,
                                     drawViewModel: drawViewModel,
                                     focused: $focusedField
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    BusinessEmailView(email: $email,
                                      drawViewModel: drawViewModel,
                                      focused: $focusedField
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    BusinessPhoneView(phone: $phone,
                                      drawViewModel: drawViewModel,
                                      focused: $focusedField
                    )
                    .padding([.top, .bottom],
                             10
                    )
                    
                    BusinessPositionView(position: $position,
                                         drawViewModel: drawViewModel
                    )
                    .padding(.top,
                             10
                    )
                    .padding(.bottom,
                             30
                    )
                    
                    SaveEntryView(name: $name,
                                  businessName: $businessName,
                                  email: $email,
                                  phone: $phone,
                                  position: $position,
                                  shouldShowConfirmation: $shouldShowConfirmation,
                                  drawViewModel: drawViewModel
                    )
                    .padding(.bottom,
                             30
                    )
                }
                .scrollIndicators(.hidden)
                .frame(width: 700)
                
                Spacer()
            }
            
            if drawViewModel.shouldShowPositionList {
                BackgroundView()
                
                PositionListView(position: $position,
                                 drawViewModel: drawViewModel
                )
            } else {
                BackgroundView()
                    .hidden()
                
                PositionListView(position: $position,
                                 drawViewModel: drawViewModel
                )
                .hidden()
            }
            
            if shouldShowConfirmation {
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
            if shouldShowConfirmation == true {
                print(position)
                Task {
                    //Display an alert to mark off payment.
                    await drawViewModel.saveLeadDetailsToDatabase()
                }
                
                name = ""
                businessName = ""
                email = ""
                phone = ""
                position = ""
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                shouldShowConfirmation = false
            }
        }
        .customAlert("ALERT",
                        isPresented: $drawViewModel.displayErrorAlert,
                        showingCancelButton: $drawViewModel.shouldShowCancelButton,
                        actionText: "Ok",
                        actionOnDismiss: {
            Log.shared.writeToLogFile(atLevel: .info,
                                        withMessage: "User tapped on cancel button in alert message. Message: \(drawViewModel.alertMessage)"
            )
        },
                        action: {
            Log.shared.writeToLogFile(atLevel: .info,
                                        withMessage: "\(drawViewModel.alertMessage)"
            )
        },
                        message: {
            Text("\(drawViewModel.alertMessage)")
        }
        )
        .customAlert("ALERT",
                        isPresented: $drawViewModel.displaySuccessAlert,
                        showingCancelButton: $drawViewModel.shouldShowCancelButton,
                        actionText: "Ok",
                        actionOnDismiss: {
            Log.shared.writeToLogFile(atLevel: .info,
                                        withMessage: "User tapped on cancel button in alert message. Message: \(drawViewModel.alertMessage)"
            )
        },
                        action: {
            Log.shared.writeToLogFile(atLevel: .info,
                                        withMessage: "\(drawViewModel.alertMessage)"
            )
        },
                        message: {
            Text("\(drawViewModel.alertMessage)")
        }
        )
        .customAlert("ALERT",
                        isPresented: $drawViewModel.displayNetworkAlert,
                        showingCancelButton: $drawViewModel.shouldShowCancelButton,
                        actionText: "Ok",
                        actionOnDismiss: {
            Log.shared.writeToLogFile(atLevel: .info,
                                        withMessage: "User tapped on cancel button in alert message. Message: \(drawViewModel.alertMessage)"
            )
        },
                        action: {
            Log.shared.writeToLogFile(atLevel: .info,
                                        withMessage: "\(drawViewModel.alertMessage)"
            )
        },
                        message: {
            Text("\(drawViewModel.alertMessage)")
        }
        )
    }
}

fileprivate struct DrawTitleView: View {

    var title: String
    
    @State private var shouldShowOptions = false
    
    @ObservedObject var drawViewModel: DrawViewModel
    
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
    
    @ObservedObject var drawViewModel: DrawViewModel
    
    var focused: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Text("Customer Name:")
                .frame(width: 200,
                       height: 50,
                       alignment: .trailing
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
                
                drawViewModel.name = name
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
    
    @ObservedObject var drawViewModel: DrawViewModel
    
    var focused: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Text("Business Name:")
                .frame(width: 200,
                       height: 50,
                       alignment: .trailing
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
                
                drawViewModel.businessName = businessName
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
        
    @ObservedObject var drawViewModel: DrawViewModel
    
    var focused: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Text("Business Email:")
                .frame(width: 200,
                       height: 50,
                       alignment: .trailing
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
                
                drawViewModel.businessEmail = email
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
    
    @ObservedObject var drawViewModel: DrawViewModel
    
    var focused: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Text("Business Phone:")
                .frame(width: 200,
                       height: 50,
                       alignment: .trailing
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
            .onChange(of: phone) {
                phone = drawViewModel.editingChanged(enteredPhone: phone)
            }
            .onSubmit {
                guard phone != "" else {
                    //Display alert here
                    return
                }
                
                drawViewModel.businessPhone = phone
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
    
    @ObservedObject var drawViewModel: DrawViewModel
    
    var body: some View {
        HStack {
            Text("Position:")
                .frame(width: 200,
                       height: 50,
                       alignment: .trailing
                )
                .font(.demiBoldFontWithSize(withSize: 20))
                .padding(.leading,
                         20
                )
                .padding(.trailing,
                         10
                )
            
            Text(position)
                .frame(width: 460,
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
                    drawViewModel.shouldShowPositionList = true
                }
                .padding(.trailing,
                         20
                )
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
    
    @ObservedObject var drawViewModel: DrawViewModel
    
    var body: some View {
        Button {
            //Pay by button clicked...
            guard name != "",
                  businessName != "",
                  email != "",
                  phone != "",
                  position != ""
            else {
                drawViewModel.alertMessage = "Please make sure you have filled all the following fields:\n\nName\nBusiness Name\nBusiness Email\nBusiness Phone\nPosition at business"
                drawViewModel.shouldShowCancelButton = false
                drawViewModel.displayErrorAlert = true
                
                return
            }
            
            guard Helper.shared.validateEmail(enteredEmail: email) else {
                drawViewModel.alertMessage = "Please enter valid email."
                drawViewModel.shouldShowCancelButton = false
                drawViewModel.displayErrorAlert = true
                
                return
            }
            
            guard phone.count == 10, Helper.shared.validatePhoneNumber(phoneNumber: phone) else {
                drawViewModel.alertMessage = "Please enter valid 10-digit phone number."
                drawViewModel.shouldShowCancelButton = false
                drawViewModel.displayErrorAlert = true
                
                return
            }
            
            drawViewModel.name = name
            drawViewModel.businessName = businessName
            drawViewModel.businessEmail = email
            drawViewModel.businessPhone = phone
            drawViewModel.position = position
            
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "User is entering the following lead details: \nName: \(name), \nBusiness Name: \(businessName), \nBusiness Email: \(email), \nBusiness Phone: \(phone), \nPosition: \(drawViewModel.position)."
            )
            
            shouldShowConfirmation = true
        } label: {
            Text("Submit Entry")
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
            .frame(width: geometryReader.size.width / 2,
                   height: 350
            )
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
    
    @State var gridItems = [GridItem]()
    
    @Binding var position: String
    
    @ObservedObject var drawViewModel: DrawViewModel
    
    var body: some View {
        GeometryReader { geometryReader in
            VStack {
                HStack {
                    Button {
                        position = ""
                        drawViewModel.shouldShowPositionList = false
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20,
                                   height: 20
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
                
                LazyVGrid(columns: gridItems,
                          spacing: 20
                ) {
                    ForEach(positionList,
                            id: \.id
                    ) { positionDetail in
                        Button {
                            //Select categories for product
                            position = positionDetail.name
                            drawViewModel.shouldShowPositionList = false
                        } label: {
                            Text(positionDetail.name)
                                .frame(width: 150,
                                       height: 50
                                )
                                .font(.mediumFontWithSize(withSize: 18))
                                .foregroundStyle(Color.white)
                                .background(drawViewModel.position == positionDetail.name ?
                                            Color.qikiGreen :
                                                Color.qikiColorSelected
                                )
                                .cornerRadius(10,
                                              corners: .allCorners
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.clear,
                                                lineWidth: 1
                                               )
                                )
                                .padding([.leading, .trailing],
                                         10
                                )
                        }
                    }
                }
                .padding(.bottom,
                         20
                )
            }
            .frame(width: geometryReader.size.width / 2)
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
            .onAppear() {
                gridItems = drawViewModel.allocateGridItems()
            }
        }
    }
}

#Preview {
    DrawView(repository: DrawRepository.init(apiClientService: APIClientService(logger: Logger.init(label: ""))))
}
