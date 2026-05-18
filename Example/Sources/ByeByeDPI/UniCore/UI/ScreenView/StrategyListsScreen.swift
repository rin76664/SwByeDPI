//
//  StrategyListsScreen.swift
//  ByeByeDPI
//
//  Created by developer on 05.03.2026.
//

import SwiftUI
import SwByeDPI

struct StrategyListsScreen: View {
    
    @EnvironmentObject var manager: StrategiesManager
    
    @State fileprivate var _showListCreateSheet = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 12.0) {
                        ForEach(0..<manager.lists.count, id: \.self) { index in
                            let strategy = manager.lists[index]
                            StrategyListView(list: strategy)
                                .id(strategy.id)
                        }
                        Rectangle()
                            .frame(width: 1, height: Constants.buttonMinHeight + 12)
                            .foregroundColor(Color.clear)
                    }
                    .padding(.horizontal, 12)
                }
                .frame(maxHeight: .infinity)
                Button {
                    if (_showListCreateSheet) {
                        return
                    }
                    _showListCreateSheet = true
                } label: {
                    Text(R.string.localizable.domainsListCreate)
                        .foregroundColor(Color(R.color.grPrimary))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight, alignment: .center)
                .background(Color(R.color.bgTertiary))
                .cornerRadius(12.0)
                .padding(EdgeInsets(top: .zero, leading: 20, bottom: geometry.safeAreaInsets.bottom > 0 ? 0 : 12, trailing: 20))
                .sheet(isPresented: $_showListCreateSheet) {
                    _showListCreateSheet = false
                } content: {
                    StrategyListCtorScreen(presented: $_showListCreateSheet, initList: nil)
                }
            }
        }
        #if !os(tvOS)
        .navigationTitle(R.string.localizable.strategiesListNavTitle())
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        #endif
    }
}

#if DEBUG
#Preview {
    NavigationView {
        StrategyListsScreen()
    }
    .environmentObject(previewStrategiesManager)
}
#endif
