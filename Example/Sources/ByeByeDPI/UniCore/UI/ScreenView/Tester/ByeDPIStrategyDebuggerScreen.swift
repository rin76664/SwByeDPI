//
//  ByeDPIStrategyDebuggerScreen.swift
//  SwByeDPI
//
//  Created by developer on 10.04.2026.
//

import SwiftUI
import SwByeDPI

struct ByeDPIStrategyDebuggerScreen: View {
    
    @EnvironmentObject var domainsManager: DomainsManager
    
    @State var strategyCmdArgs: [String]
    @StateObject var debugManager: StrategyDebugManager
    
    @State fileprivate var _totalDomainRequestsCount: Int
    
    init(initTestConfig: SBDTestConfig, initStrategyCmdArgs: [String]) {
        __totalDomainRequestsCount = State(initialValue: 100000)
        _debugManager = StateObject(wrappedValue: StrategyDebugManager(baseTestConfig: initTestConfig))
        _strategyCmdArgs = State(initialValue: initStrategyCmdArgs)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            SettingsEditableInfoView(title: R.string.localizable.settingsByeDPIArgsFieldTitle(), value: Binding(get: {
                let strategy = SBDStrategy(cmdArgs: strategyCmdArgs)
                return strategy.cmdArgsLine
            }, set: { newVal in
                let newStrategy = SBDStrategy(cmdLine: newVal)
                strategyCmdArgs = newStrategy.cmdArgs
            }), leadingIcon: Image(R.image.icCodeTags))
            .disabled(debugManager.testingInProgress)
            Button {
                if (debugManager.testingInProgress) {
                    debugManager.cancelDebug()
                    return
                }
                _totalDomainRequestsCount = debugManager.debugConfig.retrieveDomains(domainLists: domainsManager.lists).count * Int(debugManager.debugConfig.domainRequestsCount)
#if DEBUG
                if (ProcessInfo.processInfo.previewMode) {
                    //Not start the real ByeDPI
                    return
                }
#endif
                debugManager.debug(strategy: SBDStrategy(cmdArgs: strategyCmdArgs), domainLists: domainsManager.lists) { _ in
                    
                }
            } label: {
                if (debugManager.testingInProgress) {
                    Text(R.string.localizable.byeDPITestStop)
                        .foregroundColor(Color(R.color.grPrimary))
                        .fontWeight(.semibold)
                } else {
                    Text(R.string.localizable.byeDPIDebugStart)
                        .foregroundColor(Color(R.color.grPrimary))
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity, minHeight: Constants.buttonMinHeight, alignment: .center)
            .background(Color(R.color.bgTertiary))
            .cornerRadius(12.0)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            Text(R.string.localizable.byeDPIDebugDetails)
            Divider()
                .padding(EdgeInsets(top: 12, leading: .zero, bottom: 12, trailing: .zero))
            if let safeDebugResult = debugManager.lastCheckResult {
                ScrollView(.vertical) {
                    StrategyTestResultView(strategyCmdArgs: safeDebugResult.strategy.cmdArgs, totalDomainRequestsCount: _totalDomainRequestsCount, domainsSuccessTestResults: safeDebugResult.sortedDomainsTestsResult.map({ domainTestResult in
                        return (domain: domainTestResult.domain, successRequestsCount: domainTestResult.successRequestsCount, failRequestsCount: domainTestResult.failedRequestsCount, successTest: domainTestResult.successTest)
                    }))
                    .id(safeDebugResult.strategy.id)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 16)
        .onAppear {
#if canImport(UIKit)
            UIApplication.shared.isIdleTimerDisabled = true
#endif
            _totalDomainRequestsCount = debugManager.debugConfig.retrieveDomains(domainLists: domainsManager.lists).count * Int(debugManager.debugConfig.domainRequestsCount)
        }
        .onDisappear {
#if canImport(UIKit)
            UIApplication.shared.isIdleTimerDisabled = false
#endif
            debugManager.cancelDebug()
        }
#if !os(tvOS)
        .navigationTitle(R.string.localizable.byeDPIDebugNavTitle())
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
#endif
#if !os(macOS)
        .toolbar {
            #if !os(tvOS)
            let imgHeight = 24.0
            #else
            let imgHeight = 32.0
            #endif
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ByeDPIStrategyTesterSettingsScreen(testConfig: debugManager.debugConfig, onUpdate: { testConfig in
                        debugManager.updateDebugConfig(testConfig)
                    }, testSingleStrategyMode: true)
                } label: {
                    Image(R.image.icSettings)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: imgHeight)
                }
            }
        }
#endif
    }
}

#if DEBUG
#Preview {
    NavigationView {
        ByeDPIStrategyDebuggerScreen(initTestConfig: previewProperties.byeDPITestConfig, initStrategyCmdArgs: previewProperties.byeDPILaunchConfig.cmdArgs)
    }
        .environmentObject(previewDomainsManager)
}
#endif
