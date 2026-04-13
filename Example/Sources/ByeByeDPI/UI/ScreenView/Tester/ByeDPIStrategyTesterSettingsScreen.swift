//
//  ByeDPIStrategyTesterSettingsScreen.swift
//  ByeByeDPI
//
//  Created by developer on 06.03.2026.
//

import SwiftUI
import SwByeDPI

struct ByeDPIStrategyTesterSettingsScreen: View {
    
    @EnvironmentObject var domainsManager: DomainsManager
    @EnvironmentObject var strategiesManager: StrategiesManager
    
    fileprivate let testSingleStrategyMode: Bool
    fileprivate let onUpdate: (SBDTestConfig) -> Void
    
    @State fileprivate var delayBetweenReqeustsInS: UInt8
    @State fileprivate var domainRequestsCount: UInt8
    @State fileprivate var threadsCount: UInt8
    @State fileprivate var domainAnswerTimeoutInS: UInt8
    @State fileprivate var testDomainIDs: [String]
    @State fileprivate var testStrategyIDs: [String]
    
    @State fileprivate var showStrategyListPickerSheet = false
    @State fileprivate var showDomainListPickerSheet = false
    
    fileprivate var config: SBDTestConfig {
        get {
            return SBDTestConfig(domainRequestsCount: domainRequestsCount, parallelRequestsCount: threadsCount, domainAnswerTimeoutInS: domainAnswerTimeoutInS, delayBetweenRequestsInS: delayBetweenReqeustsInS, fakeSNI: "google.com", domainListIDs: Set(testDomainIDs), strategyListIDs: Set(testStrategyIDs))
        }
    }
    
    init(testConfig: SBDTestConfig, onUpdate: @escaping (SBDTestConfig) -> Void, testSingleStrategyMode: Bool = false) {
        self.onUpdate = onUpdate
        _delayBetweenReqeustsInS = State(initialValue: testConfig.delayBetweenRequestsInS)
        _domainRequestsCount = State(initialValue: testConfig.domainRequestsCount)
        _threadsCount = State(initialValue: testConfig.parallelRequestsCount)
        _domainAnswerTimeoutInS = State(initialValue: testConfig.domainAnswerTimeoutInS)
        _testDomainIDs = State(initialValue: [String].init(testConfig.domainListIDs))
        _testStrategyIDs = State(initialValue: [String].init(testConfig.strategyListIDs))
        self.testSingleStrategyMode = testSingleStrategyMode
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8.0) {
                VStack(alignment: .leading) {
                    Text(R.string.localizable.settingsGeneralSection)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(R.color.grSecondary))
                    SettingsEditableInfoView(title: R.string.localizable.settingsByeDPIStrategyTestDelay(), value: Binding(get: {
                        return String(delayBetweenReqeustsInS)
                    }, set: { _ in }), leadingIcon: Image(R.image.icSettingsAlt), valueTextSuffix: " - " + R.string.localizable.settingsByeDPIStrategyTestDelayDesc(), validator: { input in
                        guard let _ = UInt8(input) else {
                            return false
                        }
                        return true
                    }, onNewValue: { input in
                        guard let parsedNum = UInt8(input) else {
                            return
                        }
                        if (delayBetweenReqeustsInS == parsedNum) {
                            return
                        }
                        delayBetweenReqeustsInS = parsedNum
                        onUpdate(config)
                    }, keyboardType: .numberPad)
                    SettingsEditableInfoView(title: R.string.localizable.settingsByeDPIStrategyTestDomainRequestsCount(), value: Binding(get: {
                        return String(domainRequestsCount)
                    }, set: { _ in }), leadingIcon: Image(R.image.icSettingsAlt), valueTextSuffix: " - " + R.string.localizable.settingsByeDPIStrategyTestDomainRequestsCountDesc(), validator: { input in
                        guard let _ = UInt8(input) else {
                            return false
                        }
                        return true
                    }, onNewValue: { input in
                        guard let parsedNum = UInt8(input) else {
                            return
                        }
                        if (domainRequestsCount == parsedNum) {
                            return
                        }
                        domainRequestsCount = parsedNum
                        onUpdate(config)
                    }, keyboardType: .numberPad)
                    SettingsEditableInfoView(title: R.string.localizable.settingsByeDPIStrategyTestThreadsCount(), value: Binding(get: {
                        return String(threadsCount)
                    }, set: { _ in }), leadingIcon: Image(R.image.icSettingsAlt), valueTextSuffix: " - " + R.string.localizable.settingsByeDPIStrategyTestThreadsCountDesc(), validator: { input in
                        guard let _ = UInt8(input) else {
                            return false
                        }
                        return true
                    }, onNewValue: { input in
                        guard let parsedNum = UInt8(input) else {
                            return
                        }
                        if (threadsCount == parsedNum) {
                            return
                        }
                        threadsCount = parsedNum
                        onUpdate(config)
                    }, keyboardType: .numberPad)
                    SettingsEditableInfoView(title: R.string.localizable.settingsByeDPIStrategyTestResponseWaitTimeout(), value: Binding(get: {
                        return String(domainAnswerTimeoutInS)
                    }, set: { _ in }), leadingIcon: Image(R.image.icSettingsAlt), valueTextSuffix: " - " + R.string.localizable.settingsByeDPIStrategyTestResponseWaitTimeoutDesc(), validator: { input in
                        guard let _ = UInt8(input) else {
                            return false
                        }
                        return true
                    }, onNewValue: { input in
                        guard let parsedNum = UInt8(input) else {
                            return
                        }
                        if (domainAnswerTimeoutInS == parsedNum) {
                            return
                        }
                        domainAnswerTimeoutInS = parsedNum
                        onUpdate(config)
                    }, keyboardType: .numberPad)
                }
                .padding(EdgeInsets(top: .zero, leading: .zero, bottom: 8.0, trailing: .zero))
                VStack(alignment: .leading) {
                    Text(R.string.localizable.settingsByeDPIStrategyTestDomainsStrategiesSection)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(R.color.grSecondary))
                    SettingsButtonView(title: R.string.localizable.settingsDomainsListOption(), text: R.string.localizable.settingsByeDPIStrategyTestDomainsOptionDesc(), leadingIcon: Image(R.image.icWorld), onPressed: {
                        if (showDomainListPickerSheet) {
                            return
                        }
                        showDomainListPickerSheet = true
                    })
                    .sheet(isPresented: $showDomainListPickerSheet, onDismiss: {
                        showDomainListPickerSheet = false
                    }, content: {
                        ListPickerScreen(lists: domainsManager.controller.domainLists.values.sorted(by: { a, b in
                            a.name.compare(b.name) == .orderedDescending
                        }), initCheckedListIDs: Set(testDomainIDs), presented: $showDomainListPickerSheet) { lists, picked in
                            testDomainIDs = [String].init(picked)
                            onUpdate(config)
                        }
                    })
                    if (!testSingleStrategyMode) {
                        SettingsButtonView(title: R.string.localizable.settingsStrategiesListOption(), text: R.string.localizable.settingsByeDPIStrategyTestStrategiesOptionDesc(), leadingIcon: Image(R.image.icGridHexagon)) {
                            if (showStrategyListPickerSheet) {
                                return
                            }
                            showStrategyListPickerSheet = true
                        }
                        .sheet(isPresented: $showStrategyListPickerSheet, onDismiss: {
                            showStrategyListPickerSheet = false
                        }, content: {
                            ListPickerScreen(lists: strategiesManager.controller.strategyLists.values.sorted(by: { a, b in
                                a.name.compare(b.name) == .orderedAscending
                            }), initCheckedListIDs: Set(testStrategyIDs), presented: $showStrategyListPickerSheet) { lists, picked in
                                testStrategyIDs = [String].init(picked)
                                onUpdate(config)
                            }
                        })
                    }
                }
                Rectangle()
                    .frame(width: 1.0, height: 12.0)
                    .opacity(0.0)
            }
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
#if !os(tvOS)
        .navigationTitle(R.string.localizable.byeDPITestSettingsNavTitle())
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
#endif
    }
}

#if DEBUG
#Preview {
    NavigationView {
        ByeDPIStrategyTesterSettingsScreen(testConfig: previewProperties.byeDPITestConfig, onUpdate: { _ in })
    }
    .environmentObject(previewDomainsManager)
    .environmentObject(previewStrategiesManager)
}
#endif
