//
//  ListRawDataScreen.swift
//  ByeByeDPI
//
//  Created by developer on 06.03.2026.
//

import SwiftUI

struct ListRawDataScreen: View {
    
    fileprivate let _rawDataLines: [String]
    @Binding fileprivate var presented: Bool
    
    init(rawDataLines: [String], presented: Binding<Bool>) {
        _rawDataLines = rawDataLines
        _presented = presented
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Rectangle()
                    .frame(width: 48, height: 4)
                    .background(Color(R.color.bgTertiary))
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                ScrollView(.vertical) {
                    LazyVStack(alignment: .center, spacing: 8.0) {
                        ForEach(0..<_rawDataLines.count, id: \.self) { index in
                            let line = _rawDataLines[index]
                            VStack(alignment: .leading, spacing: 8.0) {
                                HStack(alignment: .top, spacing: 4.0) {
                                    Text("•")
                                    Text(line)
                                }
                                Divider()
                                    .padding(EdgeInsets(top: .zero, leading: 12.0, bottom: .zero, trailing: .zero))
                            }
                            .id(line)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Rectangle()
                            .frame(width: 1, height: Constants.buttonMinHeight)
                            .foregroundColor(Color.clear)
                    }
                    .padding(EdgeInsets(top: .zero, leading: 16, bottom: 16, trailing: 8))
                }
                .padding(EdgeInsets(top: 24.0, leading: .zero, bottom: .zero, trailing: .zero))
                Button {
                    presented = false
                } label: {
                    Text(R.string.localizable.generalClose)
                        .foregroundColor(Color(R.color.grPrimary))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight, alignment: .center)
                .background(Color(R.color.bgTertiary))
                .cornerRadius(12.0)
                .padding(EdgeInsets(top: geometry.size.height - geometry.safeAreaInsets.bottom, leading: 20, bottom: .zero, trailing: 20))
            }
        }
    }
}

#Preview {
    let rawLines = [
        "Some data 1",
        "Some data 2",
        "Some data 3",
        "Some data 4",
        "Some data 5",
    ]
    var presented = true
    
    ListRawDataScreen(rawDataLines: rawLines, presented: Binding(get: {
        return presented
    }, set: { newVal in
        presented = newVal
    }))
}
