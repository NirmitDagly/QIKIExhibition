//
//  EFTPOSSettingsView.swift
//  QikiTest
//
//  Created by Miamedia Developer on 18/04/24.
//

import SwiftUI
import DesignSystem
import Network
import Router
import NVActivityIndicatorView
import Logger
import QAlert
import WebKit

struct EFTPOSSettingsView: View {
    
    @StateObject var eftposSettingsViewModel: EFTPOSViewModel
    
    @EnvironmentObject var configuration: Configuration
    
    var titleText: String
    
    init(repository: EFTPOSRepository,
         andViewTitle viewTitle: String
    ) {
        _eftposSettingsViewModel = .init(wrappedValue: EFTPOSViewModel(repository: repository))
        self.titleText = viewTitle
    }
    
    var body: some View {
        VStack {
            TitleView(title: titleText)
            
            PinpadPairingStatusView(eftposViewModel: eftposSettingsViewModel)
                .frame(height: 50)
                .padding([.top, .bottom],
                         10
                )
            
            GeometryReader { geometryReader in
                HStack {
                    VStack(alignment: .leading,
                           spacing: 0
                    ) {
                        EFTPOSConfigurationView(eftposViewModel: eftposSettingsViewModel)
                            .padding(.top,
                                     10
                            )
                        
                        EFTPOSKeypadView(eftposSettingsViewModel: eftposSettingsViewModel)
                            .padding(.trailing,
                                     20
                            )
                        
                        Spacer()
                    }
                    .frame(width: geometryReader.size.width / 2)
                    
                    Divider()
                        .frame(width: 1,
                               height: geometryReader.size.height
                        )
                    
                    InstructionView(eftposViewModel: eftposSettingsViewModel)
                        .frame(width: geometryReader.size.width / 2)
                        .padding(.trailing,
                                 20
                        )
                }
            }
        }
        .onAppear {
            eftposSettingsViewModel.getCredentialsFromDatabase()
            
            //MARK: Remove the loading demo data when shipping the code
            if eftposSettingsViewModel.linklyCredentials.count == 0 {
                eftposSettingsViewModel.saveDemoDataIntoDatabase()
            }
            
            eftposSettingsViewModel.getCredentials()
            eftposSettingsViewModel.updatePairingStatus(withMessage: "")
        }
        .customAlert("ALERT",
                     isPresented: $eftposSettingsViewModel.displayPinpadAlert,
                     showingCancelButton: $eftposSettingsViewModel.shouldShowCancelButton,
                     actionText: "Ok",
                     actionOnDismiss: {
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "User tapped on cancel button in alert message. Message: \(eftposSettingsViewModel.alertMessage)"
            )
        },
                     action: {
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "\(eftposSettingsViewModel.alertMessage)"
            )
        },
                     message: {
            Text("\(eftposSettingsViewModel.alertMessage)")
        }
        )
        .customAlert("ALERT",
                     isPresented: $eftposSettingsViewModel.displayErrorAlert,
                     showingCancelButton: $eftposSettingsViewModel.shouldShowCancelButton,
                     actionText: "Ok",
                     actionOnDismiss: {
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "User tapped on cancel button in alert message. Message: \(eftposSettingsViewModel.alertMessage)"
            )
        },
                     action: {
            Log.shared.writeToLogFile(atLevel: .info,
                                      withMessage: "\(eftposSettingsViewModel.alertMessage)"
            )
        },
                     message: {
            Text("\(eftposSettingsViewModel.alertMessage)")
        }
        )
        .ignoresSafeArea(.keyboard,
                         edges: .bottom
        )
    }
}

struct TitleView: View {
    
    var title: String
    
    var body: some View {
        HStack() {
            Spacer()
            
            Text(title)
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

struct PinpadPairingStatusView: View {
    
    @ObservedObject var eftposViewModel: EFTPOSViewModel
    
    var body: some View {
        HStack {
            Spacer()
            
            if UserDefaults.eftposPaired {
                Image("Paired",
                      label: Text("")
                )
                .resizable()
                .frame(width: 25,
                       height: 25
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.clear)
                )
                
                Text(eftposViewModel.pinpadStatus)
                
                CheckPinpadButtonView(eftposSettingsViewModel: eftposViewModel)
            } else {
                Image("Unpaired",
                      label: Text("")
                )
                .resizable()
                .frame(width: 25,
                       height: 25
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.clear)
                )
                
                Text(eftposViewModel.pinpadStatus)
            }
                        
            Spacer()
        }
    }
}

struct CheckPinpadButtonView: View {
    
    @ObservedObject var eftposSettingsViewModel: EFTPOSViewModel
    
    var body: some View {
        Button {
            Task {
                await eftposSettingsViewModel.checkPinpadStatus()
            }
        } label: {
            Text("Check Pinpad Status")
                .frame(width: 250,
                       height: 50,
                       alignment: .center
                )
                .font(.demiBoldFontWithSize(withSize: 18))
                .foregroundStyle(Color.white)
                .background(Color.qikiColor)
        }
        .cornerRadius(7,
                      corners: .allCorners
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.qikiColor,
                        lineWidth: 2
                       )
        )
        .padding(.leading,
                 20
        )
    }
}

struct EFTPOSConfigurationView: View {
    
    @ObservedObject var eftposViewModel: EFTPOSViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            LabelView()
            
            TextFieldsView(eftposSettingsViewModel: eftposViewModel)
        }
    }
}

struct LabelView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            Group {
                Text("Serial Number:")
                
                Text("Username:")
                
                Text("Password:")
                
                Text("Pairing Code:")
            }
            .frame(width: 200,
                   height: 50,
                   alignment: .leading
            )
            .font(.mediumFontWithSize(withSize: 16))
            .padding(.leading,
                     20
            )
        }
    }
}

struct TextFieldsView: View {
    
    @State private var isShowingPicker = false
    
    @State private var selectedCredential = LinklyCredentials(terminalId: "",
                                                              serialNumber: "",
                                                              userName: "",
                                                              password: ""
    )
    
    @FocusState private var isSerialNoFocused: Bool
    
    @ObservedObject var eftposSettingsViewModel: EFTPOSViewModel
    
    var body: some View {
        VStack {
            Text(eftposSettingsViewModel.selectedSerialNumber)
                .frame(width: 250,
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
                    if eftposSettingsViewModel.isEFTPOSPaired == false {
                        isShowingPicker = true
                        eftposSettingsViewModel.shouldDisplayPairingCodeGuide = false
                    }
                }
                .popover(isPresented: $isShowingPicker) {
                    Picker("",
                           selection: $selectedCredential
                    ) {
                        ForEach(eftposSettingsViewModel.linklyCredentials,
                                id: \.self
                        ) {
                            Text($0.serialNumber)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .onChange(of: selectedCredential) {
                        isShowingPicker = false
                        eftposSettingsViewModel.getCredentails(forLinklyCredentials: selectedCredential)
                    }
                }
                .padding(.trailing,
                         20
                )
            
            TextField("Enter PAX Username",
                      text: $eftposSettingsViewModel.linklyUserName
            )
            .frame(height: 50,
                   alignment: .leading
            )
            .font(.mediumFontWithSize(withSize: 16))
            .disabled(eftposSettingsViewModel.isEFTPOSPaired == true ? true : false)
            .padding(.horizontal,
                     20
            )
            .cornerRadius(10,
                          corners: .allCorners
            )
            .border(Color.gray)
            .padding(.trailing,
                     20
            )
            .padding(.top,
                     10
            )
            
            SecureField("Enter PAX Password",
                        text: $eftposSettingsViewModel.linklyPassword
            )
            .frame(height: 50,
                   alignment: .leading
            )
            .font(.mediumFontWithSize(withSize: 16))
            .disabled(eftposSettingsViewModel.isEFTPOSPaired == true ? true : false)
            .padding(.horizontal,
                     20
            )
            .cornerRadius(10,
                          corners: .allCorners
            )
            .border(Color.gray)
            .padding(.trailing,
                     20
            )
            .padding(.top,
                     10
            )
            
            TextField("Enter Pairing Code",
                      text: $eftposSettingsViewModel.pinPadPairingCode
            )
            .frame(height: 50,
                   alignment: .leading
            )
            .font(.mediumFontWithSize(withSize: 16))
            .disabled(true)
            .padding(.horizontal,
                     20
            )
            .cornerRadius(10,
                          corners: .allCorners
            )
            .border(Color.gray)
            .padding(.trailing,
                     20
            )
            .padding(.top,
                     10
            )
            .onTapGesture {
                if eftposSettingsViewModel.isEFTPOSPaired == false {
                    eftposSettingsViewModel.shouldDisplayPairingCodeGuide = true
                }
            }
        }
    }
}

struct EFTPOSKeypadView: View {
    
    @ObservedObject var eftposSettingsViewModel: EFTPOSViewModel

    var body: some View {
        HStack {
            Spacer()
            
            if eftposSettingsViewModel.shouldShowPairButton == false {
                VStack(spacing: 0) {
                    Row1View(eftposSettingsViewModel: eftposSettingsViewModel)
                    
                    Divider()
                        .frame(width: 240,
                               height: 1
                        )
                        .foregroundStyle(Color.white)
                    
                    Row2View(eftposSettingsViewModel: eftposSettingsViewModel)
                    
                    Divider()
                        .frame(width: 240,
                               height: 1
                        )
                        .foregroundStyle(Color.white)
                    
                    
                    Row3View(eftposSettingsViewModel: eftposSettingsViewModel)
                    
                    Divider()
                        .frame(width: 240,
                               height: 1
                        )
                        .foregroundStyle(Color.white)
                    
                    
                    Row4View(eftposSettingsViewModel: eftposSettingsViewModel)
                }
            } else {
                PairButtonView(eftposSettingsViewModel: eftposSettingsViewModel)
                    .padding(.top,
                             30
                    )
            }
        }
    }
}

struct Row1View: View {
    
    @ObservedObject var eftposSettingsViewModel: EFTPOSViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "1"
                )
            } label: {
                Text("1")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
            
            Divider()
                .frame(height: 80)
                .foregroundStyle(Color.white)

            
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "2"
                )
            } label: {
                Text("2")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
            
            Divider()
                .frame(height: 80)
                .foregroundStyle(Color.white)

            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "3"
                )
            } label: {
                Text("3")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
        }
    }
}

struct Row2View: View {
    
    @ObservedObject var eftposSettingsViewModel: EFTPOSViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "4"
                )
            } label: {
                Text("4")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
            
            Divider()
                .frame(height: 80)
                .foregroundStyle(Color.white)
            
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "5"
                )
            } label: {
                Text("5")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
            
            Divider()
                .frame(height: 80)
                .foregroundStyle(Color.white)
            
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "6"
                )
            } label: {
                Text("6")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
        }
    }
}

struct Row3View: View {
    
    @ObservedObject var eftposSettingsViewModel: EFTPOSViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "7"
                )
            } label: {
                Text("7")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
            
            Divider()
                .frame(height: 80)
                .foregroundStyle(Color.white)
            
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "8"
                )
            } label: {
                Text("8")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
            
            Divider()
                .frame(height: 80)
                .foregroundStyle(Color.white)
            
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "9"
                )
            } label: {
                Text("9")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
        }
    }
}

struct Row4View: View {

    @ObservedObject var eftposSettingsViewModel: EFTPOSViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: ""
                )
            } label: {
                Image(systemName: "delete.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30,
                           height: 30
                    )
                    .foregroundStyle(Color.white)
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 20))
            .foregroundStyle(Color.white)
            .background(Color.qikiRed)
            
            Divider()
                .frame(height: 80)
                .foregroundStyle(Color.white)
            
            Button {
                eftposSettingsViewModel.changeInstructionGuide()
                eftposSettingsViewModel.formatAmount(currentText: eftposSettingsViewModel.pinPadPairingCode,
                                                     userInput: "0"
                )
            } label: {
                Text("0")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.init(uiColor: UIColor.darkGray))
            
            Divider()
                .frame(height: 80)
                .foregroundStyle(Color.white)
            
            Button {
                eftposSettingsViewModel.checkAndConfirmPairCode()
            } label: {
                Text("Done")
                    .frame(width: 95,
                           height: 80
                    )
            }
            .frame(width: 95,
                   height: 80
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundStyle(Color.white)
            .background(Color.qikiGreen)
        }
    }
}

struct PairButtonView: View {
    
    @ObservedObject var eftposSettingsViewModel: EFTPOSViewModel
    
    var body: some View {
        
        Button {
            if eftposSettingsViewModel.isEFTPOSPaired == true {
                eftposSettingsViewModel.resetEFTPOSDetails()
            } else {
                guard eftposSettingsViewModel.linklyUserName != "", eftposSettingsViewModel.linklyPassword != "", eftposSettingsViewModel.pinPadPairingCode != "" else {
                    eftposSettingsViewModel.displayUsernamePasswordAlert()
                    return
                }
                
                Task {
                    await eftposSettingsViewModel.getLinklySecret()
                }
            }
        } label: {
            if eftposSettingsViewModel.isEFTPOSPaired == false {
                Text("Pair")
                    .frame(width: 290,
                           height: 50,
                           alignment: .center
                    )
                    .foregroundStyle(Color.qikiColor)
                    .font(.demiBoldFontWithSize(withSize: 20))
            } else {
                Text("Unpair")
                    .frame(width: 290,
                           height: 50,
                           alignment: .center
                    )
                    .foregroundStyle(Color.qikiColor)
                    .font(.demiBoldFontWithSize(withSize: 20))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.qikiColor,
                        lineWidth: 2
                       )
        )
    }
}

struct InstructionView: View {

    @ObservedObject var eftposViewModel: EFTPOSViewModel
    
    var body: some View {
        if eftposViewModel.shouldDisplayPairingCodeGuide == false {
            if let asset = NSDataAsset(name: "SerialNumberGuide") {
                InstructionWebDetailView(dataToShow: asset.data)
            }
        } else {
            if let asset = NSDataAsset(name: "PairingGuide") {
                InstructionWebDetailView(dataToShow: asset.data)
            }
        }
    }
}

struct InstructionWebDetailView: UIViewRepresentable {
 
    var dataToShow: Data
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let url = Bundle.main.bundleURL
        uiView.load(dataToShow,
                    mimeType: "application/pdf",
                    characterEncodingName: "",
                    baseURL: url
        )
    }
}

#Preview {
    EFTPOSSettingsView(repository: EFTPOSRepository.init(apiClientService: APIClientService(logger: Logger.init(label: ""))),
                       andViewTitle: "EFTPOS Settings"
    )
}

extension EFTPOSSettingsView {
    struct Dependencies {
        
        let apiClient: APIClientService
        
        public init(apiClient: APIClientService) {
            self.apiClient = apiClient
        }
    }
}
