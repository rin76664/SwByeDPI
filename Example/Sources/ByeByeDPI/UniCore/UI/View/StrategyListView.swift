//
//  DomainListView.swift
//  ByeByeDPI
//
//  Created by developer on 11.03.2026.
//

import SwiftUI
import SwByeDPI

struct StrategyListView: View {
    
    fileprivate static let briefStrategiesCount = 3
    
    @EnvironmentObject var manager: StrategiesManager
    
    @State fileprivate var showStrategyListEditorSheet = false
    @State fileprivate var showDeleteActionSheet = false
    
    fileprivate let _list: SBDStrategyList
    
    fileprivate var _briefStrategies: [SBDStrategy] {
        get {
            let sorted = SBDStrategyController.retrieveSortedStrategies(_list.strategies)
            var i = 0
            var res: [SBDStrategy] = []
            while (i < StrategyListView.briefStrategiesCount && i < sorted.count) {
                res.append(sorted[i])
                i += 1
            }
            return res
        }
    }
    
    fileprivate var _strategiesCountFormattedInfo: String {
        get {
            var res = R.string.localizable.settingsStrategiesCountPrefix() + " - "
            res += String(_list.strategies.count)
            return res
        }
    }
    
    init(list: SBDStrategyList) {
        _list = list
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack(alignment: .center, spacing: 8.0) {
                VStack(alignment: .leading, spacing: 0, content: {
                    Text(_list.name)
                        .font(.body).fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(R.color.grPrimary))
                    Text(_strategiesCountFormattedInfo)
                        .font(.caption).fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(R.color.grSecondary))
                })
                Spacer(minLength: 8)
                Button {
                    if (showStrategyListEditorSheet) {
                        return
                    }
                    showStrategyListEditorSheet = true
                } label: {
                    Image(R.image.icEdit)
                        .resizable()
                        .frame(width: 20, height: 22)
                        .foregroundColor(Color(R.color.grAccent))
                }
                .frame(width: 26, height: 28, alignment: .center)
                .cornerRadius(32)
                .sheet(isPresented: $showStrategyListEditorSheet, onDismiss: {
                    showStrategyListEditorSheet = false
                }, content: {
                    StrategyListCtorScreen(presented: $showStrategyListEditorSheet, initList: _list)
                })

#if os(macOS)
                Button {
                    manager.controller.deleteItemLists(listKeys: Set([
                        _list.id
                    ]))
                } label: {
                    Image(R.image.icTrash)
                        .resizable()
                        .frame(width: 20, height: 22)
                        .foregroundColor(Color(R.color.grError))
                }
                .frame(width: 26, height: 28, alignment: .center)
                .cornerRadius(32)
#else
                Button {
                    if (showDeleteActionSheet) {
                        return
                    }
                    showDeleteActionSheet = true
                } label: {
                    Image(R.image.icTrash)
                        .resizable()
                        .frame(width: 20, height: 22)
                        .foregroundColor(Color(R.color.grError))
                }
                .frame(width: 26, height: 28, alignment: .center)
                .cornerRadius(32)
                .actionSheet(isPresented: $showDeleteActionSheet, content: {
                    ActionSheet(title: Text(R.string.localizable.generalDeleteSheetTitle), buttons: [
                        .destructive(Text(R.string.localizable.generalDelete), action: {
                            manager.controller.deleteItemLists(listKeys: Set([
                                _list.id
                            ]))
                            showDeleteActionSheet = false
                        }),
                        .cancel(Text(R.string.localizable.generalCancel), action: {
                            showDeleteActionSheet = false
                        })
                    ])
                })
#endif
            }
            ForEach(_briefStrategies, id: \.self) { strategy in
                HStack(alignment: .top, spacing: 4.0) {
                    Text("•")
                    Text(strategy.cmdArgsLine)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        .background(Color(R.color.bgSecondary))
        .cornerRadius(12.0)
    }
}

#if DEBUG
#Preview {
    StrategyListView(list: SBDStrategyList(name: "Preview strategy list", strategies: BuiltInDPIeStrategies.strategiesList.strategies))
        .environmentObject(previewStrategiesManager)
}
#endif
