//
//  SettingsInfoView.swift
//  SwByeDPI
//
//  Created by developer on 02.03.2026.
//

import SwiftUI

struct SettingsButtonView: View {
    
    fileprivate let title: String
    fileprivate let text: String
    fileprivate let leadingIcon: Image
    
    fileprivate let onPressed: () -> Void
    
    init(title: String, text: String, leadingIcon: Image, onPressed: @escaping () -> Void) {
        self.title = title
        self.text = text
        self.leadingIcon = leadingIcon
        self.onPressed = onPressed
    }
    
    var body: some View {
        Button(action: onPressed) {
            HStack(alignment: .center, spacing: 12.0) {
                leadingIcon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(R.color.grSecondary))
                VStack(alignment: .leading, spacing: 0, content: {
                    Text(title)
                        .font(.caption).fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(R.color.grSecondary))
                    Text(text)
                        .font(.body).fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(R.color.grPrimary))
                })
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        .background(Color(R.color.bgSecondary))
        .cornerRadius(12.0)
    }
}

#Preview {
    SettingsButtonView(title: "Some category", text: "Category Value", leadingIcon: Image(R.image.icInfo)) {
        
    }
}
