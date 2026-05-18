//
//  DomainListView.swift
//  ByeByeDPI
//
//  Created by developer on 11.03.2026.
//

import SwiftUI
import SwByeDPI

struct DomainListView: View {
    
    fileprivate static let briefDomainsCount = 4
    
    @EnvironmentObject var manager: DomainsManager
    
    @State fileprivate var showDomainListEditorSheet = false
    @State fileprivate var showDeleteActionSheet = false
    
    fileprivate let _list: SBDDomainList
    
    fileprivate var _briefDomains: [String] {
        get {
            let sorted = SBDDomainController.retrieveSortedDomains(_list.domains)
            var i = 0
            var res: [String] = []
            while (i < DomainListView.briefDomainsCount && i < sorted.count) {
                res.append(sorted[i])
                i += 1
            }
            return res
        }
    }
    
    fileprivate var _domainsCountFormattedInfo: String {
        get {
            var res = R.string.localizable.settingsDomainsCountPrefix() + " - "
            res += String(_list.domains.count)
            return res
        }
    }
    
    init(list: SBDDomainList) {
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
                    Text(_domainsCountFormattedInfo)
                        .font(.caption).fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(R.color.grSecondary))
                })
                Spacer(minLength: 8)
                Button {
                    if (showDomainListEditorSheet) {
                        return
                    }
                    showDomainListEditorSheet = true
                } label: {
                    Image(R.image.icEdit)
                        .resizable()
                        .frame(width: 20, height: 22)
                        .foregroundColor(Color(R.color.grAccent))
                }
                .frame(width: 26, height: 28, alignment: .center)
                .cornerRadius(32)
                .sheet(isPresented: $showDomainListEditorSheet, onDismiss: {
                    showDomainListEditorSheet = false
                }, content: {
                    DomainListCtorScreen(presented: $showDomainListEditorSheet, initList: _list)
                })

#if !os(macOS)
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
#else
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
#endif
            }
            ForEach(_briefDomains, id: \.self) { domain in
                HStack(alignment: .top, spacing: 4.0) {
                    Text("•")
                    Text(domain)
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
    DomainListView(list: SBDDomainList(name: "Preview domain list", domains: YouTubeTestDomains.domainsList.items))
        .environmentObject(previewDomainsManager)
}
#endif
