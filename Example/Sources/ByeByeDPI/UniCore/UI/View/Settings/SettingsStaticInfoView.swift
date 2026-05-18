//
//  SettingsInfoView.swift
//  SwByeDPI
//
//  Created by developer on 02.03.2026.
//

import SwiftUI

struct SettingsStaticInfoView: View {
    
    fileprivate let title: String
    fileprivate let text: String
    fileprivate let leadingIcon: Image
    
    init(title: String, text: String, leadingIcon: Image) {
        self.title = title
        self.text = text
        self.leadingIcon = leadingIcon
    }
    
    var body: some View {
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
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        .background(Color(R.color.bgSecondary))
        .cornerRadius(12.0)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 12.0) {
        SettingsStaticInfoView(title: "Some category", text: "Category Value", leadingIcon: Image(R.image.icInfo))
        SettingsStaticInfoView(title: "Some category long-long-long text with additional info...", text: "Category Value", leadingIcon: Image(R.image.icInfo))
        SettingsStaticInfoView(title: "Some category long-long-long text with additional info...", text: "Category Value long-long-long text with additional info", leadingIcon: Image(R.image.icInfo))
    }
}
#endif
