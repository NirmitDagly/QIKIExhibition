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
    
    @State var titleText = "Leads"

    @StateObject var enquiriesViewModel: EnquiriesViewModel
    
    @EnvironmentObject var router: Router
    
    init(repository: EnquiriesRepository) {
        _enquiriesViewModel = .init(wrappedValue: EnquiriesViewModel(repository: repository))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            EnquiriesTitleView(title: titleText)
            
            List {
                Section {
                    EnquiriesHeaderView(enquiriesViewModel: enquiriesViewModel)
                }
                
                Section {
                    EnquiriesListView(enquiriesViewModel: enquiriesViewModel)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear() {
            enquiriesViewModel.getAllEnquiries()
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
