//
//  DomainListCtorScreen.swift
//  ByeByeDPI
//
//  Created by developer on 12.03.2026.
//

import SwiftUI
import SwByeDPI
#if canImport(UIKit)
import UIKit
#endif

struct DomainListCtorScreen: View {
    
    @EnvironmentObject var manager: DomainsManager
    
    fileprivate let _listEditKey: String?
    @State fileprivate var _name: String
    @State fileprivate var _domainsText: String
    @State fileprivate var _err = ""
    
    @Binding fileprivate var presented: Bool
    
    fileprivate var _uniqueDomains: Set<String> {
        get {
            var res = Set<String>()
            let splitted = _domainsText.split(separator: "\n")
            for line in splitted {
                let innerSplit = line.split(separator: " ")
                for domain in innerSplit {
                    let str = String(domain)
                    if (res.contains(str)) {
                        continue
                    }
                    res.insert(str)
                }
            }
            return res
        }
    }
    
    fileprivate var _createMode: Bool {
        get {
            return _listEditKey == nil
        }
    }
    
    fileprivate var _editMode: Bool {
        get {
            return !_createMode
        }
    }
    
    fileprivate var _navTitle: String {
        var title = R.string.localizable.domainsListCtorEditNavTitle()
        if (_createMode) {
            title = R.string.localizable.domainsListCtorCreateNavTitle()
        }
        return title
    }
    
    init(presented: Binding<Bool>, initList: SBDDomainList?) {
        _listEditKey = initList?.id
        self._presented = presented
        guard let safeInitList = initList else {
            __name = State(initialValue: "")
            __domainsText = State(initialValue: "")
            return
        }
        __name = State(initialValue: safeInitList.name)
        __domainsText = State(initialValue: safeInitList.rawItems.joined(separator: "\n"))
    }
    
    var body: some View {
        ZStack {
            Form(content: {})
                .background(Color(R.color.bgPrimary).ignoresSafeArea(edges: .all))
                .alignmentGuide(.top, computeValue: { dimension in
                    return 0
                })
                .onTapGesture {
                    _err = ""
#if canImport(UIKit)
                    UIApplication.shared.endEditing()
#endif
                }
            VStack(alignment: .center, spacing: .zero) {
                Rectangle()
                    .frame(width: 48, height: 4)
                    .background(Color(R.color.bgTertiary))
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
                Text(_navTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(R.color.grPrimary))
                Text(R.string.localizable.domainsListCtorName)
                    .padding(EdgeInsets(top: 32, leading: .zero, bottom: .zero, trailing: .zero))
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField(R.string.localizable.domainsListCtorName(), text: $_name)
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                #if !os(tvOS)
                    .textFieldStyle(.roundedBorder)
                #endif
                    .onTapGesture {
                        if (_editMode) {
                            return
                        }
                        _err = ""
                    }
                    .disabled(_editMode)
                Text(R.string.localizable.domainsListCtorItems)
                    .padding(EdgeInsets(top: 24, leading: .zero, bottom: .zero, trailing: .zero))
                    .frame(maxWidth: .infinity, alignment: .leading)
                #if os(tvOS) || os(macOS)
                TextField(R.string.localizable.domainsListCtorItemsHint(), text: $_domainsText)
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                    .lineLimit(4)
                    .onTapGesture {
                        _err = ""
                    }
                #else
                TextEditor(text: $_domainsText)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(R.color.bgSecondary), lineWidth: 1))
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                    .onTapGesture {
                        _err = ""
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                #endif
    
                Spacer(minLength: 8)
                Text(_err)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(Color(R.color.grError))
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8.0)
                HStack(alignment: .center, spacing: 8.0) {
                    Button {
                        presented = false
                    } label: {
                        Text(R.string.localizable.generalCancel)
                            .foregroundColor(Color(R.color.grPrimary))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight, alignment: .center)
                    .background(Color(R.color.bgTertiary))
                    .cornerRadius(12.0)
                    
                    Button {
                        if (_name.isEmpty) {
                            _err = R.string.localizable.domainsListCtorEmptyName()
                            return
                        }
                        if (_domainsText.isEmpty) {
                            _err = R.string.localizable.domainsListCtorNoDomains()
                            return
                        }
                        if let safeEditListKey = _listEditKey {
                            _ = manager.controller.updateItemsInList(listKey: safeEditListKey, items: _uniqueDomains)
                            presented = false
                            return
                        }
                        var createdList = SBDDomainList(name: _name, domains: Set())
                        if (manager.controller.listExists(id: createdList.id)) {
                            _err = R.string.localizable.domainsListCtorListExists()
                            return
                        }
                        createdList = SBDDomainList(name: _name, domains: _uniqueDomains)
                        manager.controller.addListItems([createdList])
                        presented = false
                    } label: {
                        Text(R.string.localizable.generalDone)
                            .foregroundColor(Color(R.color.grPrimary))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight, alignment: .center)
                    .background(Color(R.color.bgTertiary))
                    .cornerRadius(12.0)
                }
                Rectangle()
                    .frame(width: 1.0, height: 12.0)
                    .opacity(0.0)
            }
            .padding(.horizontal, 16)
        }
    }
}

#if DEBUG
#Preview {
    DomainListCtorScreen(presented: Binding(get: {
        return true
    }, set: { newVal in
        
    }), initList: nil)
    .environmentObject(previewDomainsManager)
}
#endif
