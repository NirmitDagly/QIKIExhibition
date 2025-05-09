//
//  EnquiriesView.swift
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
import QAlert

struct EnquiriesView: View {
    
    @State var titleText = "Competition Entries"
    
    @State var shouldShowPasswordAlert = true
    
    @State var shouldDisplayLeads = false

    @StateObject var enquiriesViewModel: EnquiriesViewModel
    
    @EnvironmentObject var router: Router
    
    init(repository: EnquiriesRepository) {
        _enquiriesViewModel = .init(wrappedValue: EnquiriesViewModel(repository: repository))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                EnquiriesTitleView(title: titleText)
                
                if shouldShowPasswordAlert {
                    Spacer()
                    
                    PasswordView(shouldShowPasswordAlert: $shouldShowPasswordAlert,
                                 shouldDisplayLeads: $shouldDisplayLeads,
                                 enquiriesViewModel: enquiriesViewModel
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
                    
                    Spacer()
                }
                
                if shouldDisplayLeads == true {
                    List {
                        Section {
                            EnquiriesHeaderView(enquiriesViewModel: enquiriesViewModel)
                        }
                        
                        Section {
                            EnquiriesListView(enquiriesViewModel: enquiriesViewModel)
                        }
                    }
                    .scrollIndicators(.hidden)
                } else {
                    Spacer()
                }
            }
        }
        .onAppear() {
            shouldShowPasswordAlert = true
        }
        .onDisappear {
            shouldShowPasswordAlert = true
            shouldDisplayLeads = false
        }
    }
}

struct EnquiriesTitleView: View {
    
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

struct EnquiriesHeaderView: View {
    
    @ObservedObject var enquiriesViewModel: EnquiriesViewModel
    
    var body: some View {
        HStack {
            Text("Name")
                .frame(width: 200,
                       height: 50
                )
                .font(.mediumFontWithSize(withSize: 16))
                .foregroundStyle(Color.qikiColor)
            
            Divider()
                .frame(width: 2,
                       height: 50
                )
                .background(Color.black)
            
            Text("Business Name")
                .frame(width: 200,
                       height: 50
                )
                .font(.mediumFontWithSize(withSize: 16))
                .foregroundStyle(Color.qikiColor)
            
            Divider()
                .frame(width: 2,
                       height: 50
                )
                .background(Color.black)
            
            Text("Business Phone")
                .frame(width: 200,
                       height: 50
                )
                .font(.mediumFontWithSize(withSize: 16))
                .foregroundStyle(Color.qikiColor)
            
            Divider()
                .frame(width: 2,
                       height: 50
                )
                .background(Color.black)

            Text("Business Email")
                .frame(width: 200,
                       height: 50
                )
                .font(.mediumFontWithSize(withSize: 16))
                .foregroundStyle(Color.qikiColor)
            
            Divider()
                .frame(width: 2,
                       height: 50
                )
                .background(Color.black)
            
            Text("Position")
                .frame(width: 200,
                       height: 50
                )
                .font(.mediumFontWithSize(withSize: 16))
                .foregroundStyle(Color.qikiColor)
        }
    }
}

struct EnquiriesListView: View {
    
    @ObservedObject var enquiriesViewModel: EnquiriesViewModel

    var body: some View {
        ForEach(enquiriesViewModel.enquiries,
                id: \.id
        ) { inquiryData in
            HStack {
                Text(inquiryData.name)
                    .frame(width: 200,
                           height: 50
                    )
                    .frame(alignment: .leading)
                    .font(.mediumFontWithSize(withSize: 16))
                    .truncationMode(.tail)
                    .lineLimit(nil)
                
                Divider()
                    .frame(width: 2,
                           height: 50
                    )
                    .background(Color.black)
                
                Text(inquiryData.businessName)
                    .frame(width: 200,
                           height: 50
                    )
                    .font(.mediumFontWithSize(withSize: 16))
                    .truncationMode(.tail)
                    .lineLimit(nil)
                
                Divider()
                    .frame(width: 2,
                           height: 50
                    )
                    .background(Color.black)
                
                Text(inquiryData.businessPhone)
                    .frame(width: 200,
                           height: 50
                    )
                    .font(.mediumFontWithSize(withSize: 16))
                    .truncationMode(.tail)
                    .lineLimit(nil)
                
                Divider()
                    .frame(width: 2,
                           height: 50
                    )
                    .background(Color.black)

                Text(inquiryData.businessEmail)
                    .frame(width: 200,
                           height: 50
                    )
                    .font(.mediumFontWithSize(withSize: 16))
                    .truncationMode(.tail)
                    .lineLimit(nil)
                
                Divider()
                    .frame(width: 2,
                           height: 50
                    )
                    .background(Color.black)
                
                Text("\(inquiryData.position)")
                    .frame(width: 200,
                           height: 50
                    )
                    .font(.mediumFontWithSize(withSize: 16))
                    .truncationMode(.tail)
                    .lineLimit(nil)
            }
        }
    }
}

struct PasswordView: View {
    
    @State var password = ""
    
    @State var shouldDisplayErrorMessage = false
    
    @Binding var shouldShowPasswordAlert: Bool
    
    @Binding var shouldDisplayLeads: Bool
    
    @ObservedObject var enquiriesViewModel: EnquiriesViewModel
    
    var body: some View {
        VStack {
            Text("Please enter your password to view competition entries.")
                .frame(height: 50)
                .font(.mediumFontWithSize(withSize: 18))
            
            if shouldDisplayErrorMessage {
                Text("(Please enter correct password.)")
                    .frame(height: 30)
                    .font(.demiBoldFontWithSize(withSize: 16))
                    .foregroundStyle(.red)
            }
            
            SecureField("Enter Password",
                        text: $password
            )
            .frame(width: 200,
                   height: 50,
                   alignment: .center
            )
            .font(.mediumFontWithSize(withSize: 16))
            .foregroundColor(.black)
            .padding(.horizontal,
                     20
            )
            .keyboardType(.numberPad)
            .submitLabel(.done)
            .onSubmit {
                if password == "4242" {
                    shouldShowPasswordAlert = false
                    shouldDisplayErrorMessage = false
                    enquiriesViewModel.getAllEnquiries()
                    shouldDisplayLeads = true
                } else {
                    shouldDisplayErrorMessage = true
                }
            }
            .cornerRadius(7,
                          corners: .allCorners
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.gray,
                            lineWidth: 2
                           )
            )
            .padding()
            
            Button {
                if password == "4242" {
                    shouldShowPasswordAlert = false
                    shouldDisplayErrorMessage = false
                    enquiriesViewModel.getAllEnquiries()
                    shouldDisplayLeads = true
                } else {
                    shouldDisplayErrorMessage = true
                }
            } label: {
                Text("Ok")
                    .font(.headline).bold()
                    .frame(width: 250,
                           height: 50
                    )
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .background(Color.qikiColor)
            }
            .frame(width: 250,
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
}

#Preview {
    EnquiriesView(repository: EnquiriesRepository())
}

extension EnquiriesView {
    struct Dependencies {
        
        let apiClient: APIClientService
        
        public init(apiClient: APIClientService) {
            self.apiClient = apiClient
        }
    }
}
