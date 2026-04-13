//
//  TestManager.swift
//  SwByeDPI
//
//  Created by developer on 13.03.2026.
//

import SwiftUI
import SwByeDPI

class StrategyDebugManager: ObservableObject {
    
    fileprivate let _controller: SBDTestController
    
    @Published fileprivate(set) var debugConfig: SBDTestConfig
    @Published fileprivate(set) var lastCheckResult: SBDStrategyTestResult?
    @Published fileprivate(set) var testingInProgress: Bool
    fileprivate var _lastCheckResultSuccessRequests: Int
    
#if DEBUG
    init(config: SBDTestConfig?, lastCheckResult: SBDStrategyTestResult?) {
        _controller = SBDTestController()
        self.debugConfig = config ?? SBDTestConfig(domainRequestsCount: 2, parallelRequestsCount: 10, domainAnswerTimeoutInS: 5, delayBetweenRequestsInS: 1, fakeSNI: "google.com", domainListIDs: Set(), strategyListIDs: Set())
        self.lastCheckResult = lastCheckResult
        _lastCheckResultSuccessRequests = lastCheckResult?.successDomainRequestsCount ?? 0
        self.testingInProgress = false
    }
#endif

    init(baseTestConfig: SBDTestConfig? = nil) {
        _controller = SBDTestController()
        self.debugConfig = baseTestConfig ?? SBDTestConfig(domainRequestsCount: 2, parallelRequestsCount: 10, domainAnswerTimeoutInS: 5, delayBetweenRequestsInS: 1, fakeSNI: "google.com", domainListIDs: Set(), strategyListIDs: Set())
        self.lastCheckResult = nil
        _lastCheckResultSuccessRequests = 0
        self.testingInProgress = false
    }
    
    func updateDebugConfig(_ config: SBDTestConfig) {
        debugConfig = config
    }
    
    func debug(strategy: SBDStrategy, domainLists: [SBDDomainList], completion: @escaping (_ result: Result<[SBDStrategyTestResult], SBDError>) -> Void) {
        if (!_controller.canStartTest) {
            return
        }
        let domains = SBDDomainController.retrieveSortedDomains(debugConfig.retrieveDomains(domainLists: domainLists))
        var emptyDomainsTestResults: [String: SBDDomainTestResult] = [:]
        for domain in domains {
            emptyDomainsTestResults[domain] = SBDDomainTestResult(domain: domain, successRequestsCount: 0, failedRequestsCount: debugConfig.domainRequestsCount)
        }
        lastCheckResult = SBDStrategyTestResult(strategy: strategy, domainsTestResult: emptyDomainsTestResults)
        _lastCheckResultSuccessRequests = 0
        NotificationCenter.default.addObserver(forName: .SBDTestedStrategy, object: nil, queue: .main, using: onTestedStrategy)
        NotificationCenter.default.addObserver(forName: .SBDTestedStrategyDomain, object: nil, queue: .main, using: onTestedStrategyDomain)
        testingInProgress = true
        _controller.test(config: debugConfig, domains: domains, strategies: [strategy]) { result in
            NotificationCenter.default.removeObserver(self, name: .SBDTestedStrategy, object: nil)
            NotificationCenter.default.removeObserver(self, name: .SBDTestedStrategyDomain, object: nil)
            self.testingInProgress = false
            do {
                let testResult = try result.get()
                DispatchQueue.main.async {
                    if let safeResult = testResult.first {
                        self.lastCheckResult = safeResult
                        self._lastCheckResultSuccessRequests = safeResult.successDomainRequestsCount
                    }
                }
            } catch {
                print(error)
            }
            completion(result)
        }
    }
    
    func cancelDebug() {
        NotificationCenter.default.removeObserver(self, name: .SBDTestedStrategy, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SBDTestedStrategyDomain, object: nil)
        _controller.cancelTest()
        self.testingInProgress = false
    }
    
    fileprivate func onTestedStrategy(_ notification: Notification) {
        let parseRes = notification.tryParseTestedStrategyFromNotification()
        guard let safeTestRes = parseRes.1 else {
            return
        }
        lastCheckResult = safeTestRes
        _lastCheckResultSuccessRequests = safeTestRes.successDomainRequestsCount
        self.testingInProgress = false
    }
    
    fileprivate func onTestedStrategyDomain(_ notification: Notification) {
        let parseRes = notification.tryParseTestedStrategyDomainFromNotification()
        guard let safeTestRes = parseRes.1 else {
            return
        }
        var updDict = lastCheckResult?.domainsTestsResult
        updDict?[safeTestRes.domain] = safeTestRes
        lastCheckResult = lastCheckResult?.copyWith(domainsTestsResult: updDict)
        _lastCheckResultSuccessRequests += Int(safeTestRes.successRequestsCount)
    }
}
