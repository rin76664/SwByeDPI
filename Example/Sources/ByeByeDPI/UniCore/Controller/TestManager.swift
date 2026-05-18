//
//  TestManager.swift
//  SwByeDPI
//
//  Created by developer on 13.03.2026.
//

import SwiftUI
import SwByeDPI

class TestManager: ObservableObject {
    
    fileprivate static let _resultsStorageFilename = Constants.PSEUDO_BUNDLE_ID + ".test.results"
    
    fileprivate let _controller: SBDTestController
    
    @Published fileprivate(set) var lastCheckResults: [SBDStrategyTestResult]
    fileprivate var _lastCheckResultsIndices: [Int: Int]
    fileprivate var _lastCheckResultsSuccessRequests: [Int: Int]
    
    var checkResults: [Int: SBDStrategyTestResult] {
        get {
            var res: [Int: SBDStrategyTestResult] = [:]
            for checkRes in lastCheckResults {
                res[checkRes.strategy.id] = checkRes
            }
            return res
        }
    }
    
    var testingInProgress: Bool {
        get {
            return _controller.testingInProgress
        }
    }
    
#if DEBUG
    init(lastCheckResults: [SBDStrategyTestResult]) {
        _controller = SBDTestController()
        self.lastCheckResults = lastCheckResults
        _lastCheckResultsIndices = [:]
        _lastCheckResultsSuccessRequests = [:]
        var iterator = 0
        for res in lastCheckResults {
            _lastCheckResultsIndices[res.strategy.id] = iterator
            _lastCheckResultsSuccessRequests[res.strategy.id] = res.successDomainRequestsCount
            iterator += 1
        }
    }
#endif

    init() {
        _controller = SBDTestController()
        let loadedResults = TestManager.loadSortedLists()
        if (loadedResults.isEmpty) {
            lastCheckResults = []
            _lastCheckResultsIndices = [:]
            _lastCheckResultsSuccessRequests = [:]
            return
        }
        var indicies: [Int: Int] = [:]
        var successRequests: [Int: Int] = [:]
        for i in 0..<loadedResults.count {
            let testRes = loadedResults[i]
            indicies[testRes.strategy.id] = i
            successRequests[testRes.strategy.id] = testRes.successDomainRequestsCount
        }
        lastCheckResults = loadedResults
        _lastCheckResultsIndices = indicies
        _lastCheckResultsSuccessRequests = successRequests
    }
    
    func test(config: SBDTestConfig, domainLists: [SBDDomainList], strategyLists: [SBDStrategyList], completion: @escaping (_ result: Result<[SBDStrategyTestResult], SBDError>) -> Void) {
        if (!_controller.canStartTest) {
            return
        }
        _lastCheckResultsIndices.removeAll()
        _lastCheckResultsSuccessRequests.removeAll()
        TestManager.saveSortedLists([])
        var checkResults: [SBDStrategyTestResult] = []
        let strategies = SBDStrategyController.retrieveSortedStrategies(config.retrieveStrategies(strategyLists: strategyLists))
        let domains = SBDDomainController.retrieveSortedDomains(config.retrieveDomains(domainLists: domainLists))
        var emptyDomainsTestResults: [String: SBDDomainTestResult] = [:]
        for domain in domains {
            emptyDomainsTestResults[domain] = SBDDomainTestResult(domain: domain, successRequestsCount: 0, failedRequestsCount: config.domainRequestsCount)
        }
        for i in 0..<strategies.count {
            let strategy = strategies[i]
            checkResults.append(SBDStrategyTestResult(strategy: strategy, domainsTestResult: emptyDomainsTestResults))
            _lastCheckResultsIndices[strategy.id] = i
            _lastCheckResultsSuccessRequests[strategy.id] = 0
        }
        lastCheckResults = checkResults
        NotificationCenter.default.addObserver(forName: .SBDTestedStrategy, object: nil, queue: .main, using: onTestedStrategy)
        NotificationCenter.default.addObserver(forName: .SBDTestedStrategyDomain, object: nil, queue: .main, using: onTestedStrategyDomain)
        _controller.test(config: config, domains: domains, strategies: strategies) { result in
            NotificationCenter.default.removeObserver(self, name: .SBDTestedStrategy, object: nil)
            NotificationCenter.default.removeObserver(self, name: .SBDTestedStrategyDomain, object: nil)
            do {
                let testResult = try result.get()
                DispatchQueue.main.async {
                    self.lastCheckResults = testResult
                }
            } catch {
                print(error)
            }
            completion(result)
        }
    }
    
    func cancelTest() {
        NotificationCenter.default.removeObserver(self, name: .SBDTestedStrategy, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SBDTestedStrategyDomain, object: nil)
        _controller.cancelTest()
    }
    
    fileprivate func onTestedStrategy(_ notification: Notification) {
        let parseRes = notification.tryParseTestedStrategyFromNotification()
        guard let safeTestRes = parseRes.1 else {
            return
        }
        var index = -1
        if let safeIndex = _lastCheckResultsIndices[safeTestRes.strategy.id] {
            index = safeIndex
        } else {
            for i in 0..<lastCheckResults.count {
                if (lastCheckResults[i].strategy.id != safeTestRes.strategy.id) {
                    continue
                }
                index = i
                _lastCheckResultsIndices[safeTestRes.strategy.id] = i
                break
            }
        }
        if (index < 0) {
            return
        }
        _lastCheckResultsSuccessRequests[safeTestRes.strategy.id] = safeTestRes.successDomainRequestsCount
        //Sort check results (successful strategies go up)
        var sortCheckResults = [SBDStrategyTestResult].init(lastCheckResults)
        sortCheckResults[index] = safeTestRes
        sortCheckResults.sort { a, b in
            var cachedSuccessCount = _lastCheckResultsSuccessRequests[a.strategy.id]
            var aSuccessCount = 0
            if let safeCachedASuccessCount = cachedSuccessCount {
                aSuccessCount = safeCachedASuccessCount
            } else {
                aSuccessCount = a.successDomainRequestsCount
                _lastCheckResultsSuccessRequests[a.strategy.id] = aSuccessCount
            }
            cachedSuccessCount = _lastCheckResultsSuccessRequests[b.strategy.id]
            var bSuccessCount = 0
            if let safeCachedBSuccessCount = cachedSuccessCount {
                bSuccessCount = safeCachedBSuccessCount
            } else {
                bSuccessCount = b.successDomainRequestsCount
                _lastCheckResultsSuccessRequests[b.strategy.id] = bSuccessCount
            }
            return aSuccessCount > bSuccessCount
        }
        for i in 0..<sortCheckResults.count {
            _lastCheckResultsIndices[sortCheckResults[i].strategy.id] = i
        }
        lastCheckResults = sortCheckResults
        TestManager.saveSortedLists(sortCheckResults)
    }
    
    fileprivate func onTestedStrategyDomain(_ notification: Notification) {
        let parseRes = notification.tryParseTestedStrategyDomainFromNotification()
        guard let safeTestRes = parseRes.1 else {
            return
        }
        guard let safeStrategyID = notification.object as? Int, let safeStrategyIndex = _lastCheckResultsIndices[safeStrategyID] else {
            return
        }
        var updDict = lastCheckResults[safeStrategyIndex].domainsTestsResult
        updDict[safeTestRes.domain] = safeTestRes
        lastCheckResults[safeStrategyIndex] = lastCheckResults[safeStrategyIndex].copyWith(domainsTestsResult: updDict)
        if let _ = _lastCheckResultsSuccessRequests[safeStrategyID] {
            _lastCheckResultsSuccessRequests[safeStrategyID]? += lastCheckResults[safeStrategyIndex].successDomainRequestsCount
        } else {
            _lastCheckResultsSuccessRequests[safeStrategyID] = lastCheckResults[safeStrategyIndex].successDomainRequestsCount
        }
    }

    /// Export sorted test results to property list
    fileprivate static func saveSortedLists(_ lists: [SBDStrategyTestResult]) {
        if (PlistUtil.savePropertyList(lists, filename: TestManager._resultsStorageFilename)) {
            return
        }
#if DEBUG
            print("Test results not saved")
#endif
    }
    
    /// Load sorted test results from property list
    fileprivate static func loadSortedLists() -> [SBDStrategyTestResult] {
        guard let parsedLists: [SBDStrategyTestResult] = PlistUtil.parsePropertyList(filename: TestManager._resultsStorageFilename) else {
            return []
        }
        return parsedLists
    }
}
