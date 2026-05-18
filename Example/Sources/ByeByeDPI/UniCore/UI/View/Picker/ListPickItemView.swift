//
//  DomainListPickView.swift
//  ByeByeDPI
//
//  Created by developer on 06.03.2026.
//

import SwiftUI
import SwByeDPI

struct ListPickItemView<T: SBDNamedListDelegate>: View {
    
    fileprivate let list: T
    @Binding fileprivate var picked: Bool
    @State fileprivate var showListItemRawDataSheet = false
    
    fileprivate let onChanged: (T, Bool) -> Void
    
    fileprivate var listItemsCountFormattedInfo: String {
        get {
            var res = R.string.localizable.settingsItemsCountPrefix() + " - "
            res += String(list.items.count)
            return res
        }
    }
    
    init(list: T, picked: Binding<Bool>, onChanged: @escaping (T, Bool) -> Void) {
        self.list = list
        _picked = picked
        self.onChanged = onChanged
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Toggle(isOn: $picked) {
                VStack(alignment: .leading, spacing: 2.0) {
                    Button {
                        if (showListItemRawDataSheet) {
                            return
                        }
                        showListItemRawDataSheet = true
                    } label: {
                        Text(list.name)
                            .font(.body).fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(R.color.grAccent))
                    }
                    Text(listItemsCountFormattedInfo)
                        .font(.caption).fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(R.color.grSecondary))
                }
            }
            Divider()
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4.0))
        .sheet(isPresented: $showListItemRawDataSheet, onDismiss: {
            showListItemRawDataSheet = false
        }, content: {
            ListRawDataScreen(rawDataLines: list.rawItems, presented: $showListItemRawDataSheet)
        })
    }
}

#Preview {
    let domainList = SBDDomainList(name: "PreviewDomainList", domains: Set([
        "domain.com",
        "domain2.com",
        "domain3.com",
        "domain4.com",
        "domain5.com",
    ]))
    var domainPicked = false
    let strategyList = SBDStrategyList(name: "PreviewStrategyList", strategies: Set<SBDStrategy>([
        SBDStrategy(cmdLine: "-a 1 -Y"),
        SBDStrategy(cmdLine: "-f 1 -T 2"),
        SBDStrategy(cmdLine: "--auto=torst -f 1 -T 2"),
        SBDStrategy(cmdLine: "--auto=none -f 1 -T 2"),
        SBDStrategy(cmdLine: "--auto=bad_ssl -f 1 -T 2"),
    ]))
    var strategyPicked = false
    
    VStack(alignment: .leading, spacing: 8.0) {
        ListPickItemView(list: domainList, picked: Binding(get: {
            return domainPicked
        }, set: { newVal in
            domainPicked = newVal
        })) { list, newPickVal in
            domainPicked = newPickVal
        }
        ListPickItemView(list: strategyList, picked: Binding(get: {
            return strategyPicked
        }, set: { newVal in
            strategyPicked = newVal
        })) { list, newPickVal in
            strategyPicked = newPickVal
        }
    }
}
