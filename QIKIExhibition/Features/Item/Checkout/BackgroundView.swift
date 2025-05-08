//
//  BackgroundView.swift
//  QIKIExhibition
//
//  Created by Miamedia on 6/5/2025.
//

import SwiftUI

struct BackgroundView: View {
    
    var body: some View {
        GeometryReader { geometryReader in
            Text("")
                .frame(width: geometryReader.size.width,
                       height: geometryReader.size.height
                )
                .background(Color.black.opacity(0.5))
        }
    }
    
}

#Preview {
    BackgroundView()
}
