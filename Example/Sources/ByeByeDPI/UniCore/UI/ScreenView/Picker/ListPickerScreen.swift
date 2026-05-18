//
//  DomainListPickerScreen.swift
//  ByeByeDPI
//
//  Created by developer on 06.03.2026.
//

import SwiftUI
import SwByeDPI

struct ListPickerScreen<T: SBDNamedListDelegate>: View {
    
    fileprivate let _lists: [T]
    @State fileprivate var checkedListIDs: Set<String>
    @State fileprivate var edited: Bool
    @Binding fileprivate var presented: Bool
    
    fileprivate let _onPickConfirm: ([T], Set<String>) -> Void
    
    init(lists: [T], initCheckedListIDs: Set<String>, presented: Binding<Bool>, onPickConfirm: @escaping ([T], Set<String>) -> Void) {
        _lists = lists
        _checkedListIDs = State(initialValue: Set<String>(initCheckedListIDs))
        _edited = State(initialValue: false)
        _presented = presented
        _onPickConfirm = onPickConfirm
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack(alignment: .center, spacing: .zero) {
                    Rectangle()
                        .frame(width: 48, height: 4)
                        .background(Color(R.color.bgTertiary))
                        .cornerRadius(8)
                        .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
                }
                .frame(maxHeight: .infinity, alignment: .top)
                ScrollView(.vertical) {
                    LazyVStack(alignment: .center, spacing: 8.0) {
                        ForEach(0..._lists.count - 1, id: \.self) { index in
                            let list = _lists[index]
                            ListPickItemView(list: list, picked: Binding(get: {
                                return checkedListIDs.contains(list.id)
                            }, set: { newVal in
                                edited = true
                                if (newVal) {
                                    checkedListIDs.insert(list.id)
                                    return
                                }
                                checkedListIDs.remove(list.id)
                            })) { list, newVal in
                                // no need to update - already done in binding 'set'
                            }
                            .id(list.id)
                        }
                        Rectangle()
                            .frame(width: 1, height: Constants.buttonMinHeight)
                            .foregroundColor(Color.clear)
                    }
                    .padding(EdgeInsets(top: .zero, leading: 16, bottom: 16, trailing: 8))
                }
                .frame(maxHeight: .infinity)
                .padding(EdgeInsets(top: 32.0, leading: .zero, bottom: .zero, trailing: .zero))
                Button {
                    if (!edited) {
                        presented = false
                        return
                    }
                    _onPickConfirm(_lists, checkedListIDs)
                    presented = false
                } label: {
                    Text(R.string.localizable.generalDone)
                        .foregroundColor(Color(R.color.grPrimary))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight, alignment: .center)
                .background(Color(R.color.bgTertiary))
                .cornerRadius(12.0)
                .padding(EdgeInsets(top: .zero, leading: 20, bottom: geometry.safeAreaInsets.bottom > 0 ? 0 : 12, trailing: 20))
            }
        }
    }
}

/*#Preview {
    let lists = [
        BuiltInDPIeStrategies.strategiesList
    ]
    var selected = Set<String>([])
    
    ListPickerScreen(lists: lists, initCheckedListIDs: selected, presented: Binding(get: {
        return true
    }, set: { newVal in
        
    })) { lists, picked in
        selected = picked
    }
}*/

#Preview {
    let bookDPIBypassSLD = BookTestDomains.domainsList.retrieveSLDList()
    let ytDPIBypassSLD = YouTubeTestDomains.domainsList.retrieveSLDList()
    let gvDPIBypassSLD = GoogleVideoTestDomains.domainsList.retrieveSLDList()
    let lists = [
        bookDPIBypassSLD,
        ytDPIBypassSLD,
        gvDPIBypassSLD
    ]
    var selected = Set<String>([
        ytDPIBypassSLD.id
    ])
    
    ListPickerScreen(lists: lists, initCheckedListIDs: selected, presented: Binding(get: {
        return true
    }, set: { newVal in
        
    })) { lists, picked in
        selected = picked
    }
}
