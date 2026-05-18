//
//  SBDTestController.swift
//  SwByeDPI
//
//  Created by developer on 20.02.2026.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// DPI-evasion strategy test controller
/// Supports testing through multiple threads
public class SBDTestController {
    
    static let testingProgressUpdateEventName = "SBDTestingProgressUpdate"
    static let testingStrategyUpdateEventName = "SBDTestingStrategyUpdate"
    static let noTestingStrategyUpdateEventName = "SBDNoTestingStrategyUpdate"
    static let testingStrategyProgressUpdateEventName = "SBDTestingStrategyProgressUpdate"
    static let testingStrategyDomainsProgressUpdateEventName = "SBDTestingStrategyDomainsProgressUpdate"
    static let testingDomainProgressUpdateEventName = "SBDTestingDomainProgressUpdate"
    static let testedStrategyEventName = "SBDTestedStrategy"
    static let testedStrategyDomainEventName = "SBDTestedStrategyDomain"
    
    /// Test process thread
    fileprivate var _testThread: Thread?
    /// Test process concurrent cancellation token
    fileprivate var _testThreadCancelTkSource: ConcurrentCancellationTokenSource
    
    /// Test process in progress
    public var testingInProgress: Bool {
        get {
            return _testThread != nil
        }
    }
    
    /// Can start the new test flag
    public var canStartTest: Bool {
        get {
            return _testThread == nil && !ByeDPI.proxyStarted
        }
    }
    
    public init() {
        _testThread = nil
        _testThreadCancelTkSource = ConcurrentCancellationTokenSource()
    }
    
    /// Cancels the current test, if in progress
    public func cancelTest() {
        _testThread?.cancel()
        _testThreadCancelTkSource.cancel()
        _testThread = nil
    }
    
    /// Test strategies
    /// - Parameters:
    ///   - config: ByeDPI test config
    ///   - domainLists: Domain lists for retrieving test domains
    ///   - strategyLists: Strategy lists for retrieving test strategies
    ///   - completion: Stratey test results completion handler
    public func test(config: SBDTestConfig, domainLists: [SBDDomainList], strategyLists: [SBDStrategyList], completion: @escaping (_ result: Result<[SBDStrategyTestResult], SBDError>) -> Void) {
        if (testingInProgress) {
#if DEBUG
            print("Another test in progress")
#endif
            completion(.failure(.general(errCode: -1, desc: "Another test in progress")))
            return
        }
        if (config.domainListIDs.isEmpty) {
#if DEBUG
            print("Domain list array is empty")
#endif
            completion(.failure(.general(errCode: -1, desc: "Test config domain list IDs array is empty")))
            return
        }
        let domains = SBDDomainController.retrieveSortedDomains(config.retrieveDomains(domainLists: domainLists))
        if (config.strategyListIDs.isEmpty) {
#if DEBUG
            print("Strategy list array is empty")
#endif
            completion(.failure(.general(errCode: -1, desc: "Test config strategy list IDs array is empty")))
            return
        }
        let strategies = SBDStrategyController.retrieveSortedStrategies(config.retrieveStrategies(strategyLists: strategyLists))
        test(config: config, domains: domains, strategies: strategies, completion: completion)
    }

    /// Test strategies
    /// - Parameters:
    ///   - config: ByeDPI test config
    ///   - domains: Domains for testing
    ///   - strategies: Strategies for testing
    ///   - completion: Stratey test results completion handler
    public func test(config: SBDTestConfig, domains: [String], strategies: [SBDStrategy], completion: @escaping (_ result: Result<[SBDStrategyTestResult], SBDError>) -> Void) {
        if (testingInProgress) {
#if DEBUG
            print("Another test in progress")
#endif
            completion(.failure(.general(errCode: -1, desc: "Another test in progress")))
            return
        }
        if (domains.isEmpty) {
#if DEBUG
            print("No domains for test")
#endif
            completion(.failure(.general(errCode: -1, desc: "No domains retrieved from config")))
            return
        }
        if (strategies.isEmpty) {
#if DEBUG
            print("No strategies for test")
#endif
            completion(.failure(.general(errCode: -1, desc: "No strategies retrieved from config")))
            return
        }
        
        let cancelTkSource = ConcurrentCancellationTokenSource()
        _testThreadCancelTkSource = cancelTkSource
        nonisolated(unsafe) let unsafeCompletion = completion
        SBDTestController.notifyProgressUpdate(testedStrategiesCount: 1, totalStrategiesCount: strategies.count)
        _testThread = Thread {
            var taskDomains: [[String]] = [[String]].init(repeating: [], count: Int(config.parallelRequestsCount))
            var taskI = 0
            for domain in domains {
                taskDomains[taskI % taskDomains.count].append(domain)
                taskI += 1
            }
            _ = ByeDPI.stop()
            let totalDomainRequestsCount = SBDTestController.calculateTotalRequestsCount(domainRequestsCount: Int(config.domainRequestsCount), domainsCount: domains.count)
            var strategiesScanRes: [SBDStrategyTestResult] = []
            
            SBDTestController.testRecurse(currentStrategyIndex: 0, config: config, totalDomainsCount: domains.count, totalDomainRequestsCount: totalDomainRequestsCount, strategiesScanRes: &strategiesScanRes, taskDomains: taskDomains, strategies: strategies, cancelTkSource: cancelTkSource, completion: unsafeCompletion)
        }
        _testThread?.name = "ByeDPI tester"
        _testThread?.start()
    }
    
    /// Recursive strrategy test function
    /// - Parameters:
    ///   - currentStrategyIndex: Current strqategy index
    ///   - config: ByeDPI test config
    ///   - totalDomainsCount: Total test domains count
    ///   - totalDomainRequestsCount: Total requests count
    ///   - strategiesScanRes: strategies test results ref
    ///   - taskDomains: Test domains for workers-threads
    ///   - strategies: Test strategies
    ///   - cancellationToken: Thread-safe cancellation token
    ///   - completion: Strategy test results completion handler
    private static func testRecurse(currentStrategyIndex: Int, config: SBDTestConfig, totalDomainsCount: Int, totalDomainRequestsCount: Int, strategiesScanRes: inout [SBDStrategyTestResult], taskDomains: [[String]], strategies: [SBDStrategy], cancelTkSource: ConcurrentCancellationTokenSource, completion: @escaping (_ result: Result<[SBDStrategyTestResult], SBDError>) -> Void) {
        if (Thread.current.isCancelled || cancelTkSource.cancellationToken.cancellationRequested) {
            _ = ByeDPI.stop()
            notifyNoTestingStrategy()
            if (strategiesScanRes.isEmpty) {
                completion(.failure(.general(errCode: -1, desc: "Strategy scan cancel")))
            } else {
                strategiesScanRes.sort { a, b in
                    return a.successDomainRequestsCount > b.successDomainRequestsCount
                }
                var emptyDomainsScanRes: [String: SBDDomainTestResult] = [:]
                for domains in taskDomains {
                    for domain in domains {
                        emptyDomainsScanRes[domain] = SBDDomainTestResult(domain: domain, successRequestsCount: 0, failedRequestsCount: config.domainRequestsCount)
                    }
                }
                var i = currentStrategyIndex
                while (i < strategies.count) {
                    strategiesScanRes.append(SBDStrategyTestResult(strategy: strategies[i], domainsTestResult: emptyDomainsScanRes))
                    i += 1
                }
                completion(.success(strategiesScanRes))
            }
            return
        }
        let strategy = strategies[currentStrategyIndex]
        SBDTestController.notifyTestingStrategyUpdate(strategy)
        var closureStrategiesScanRes = strategiesScanRes
#if DEBUG
        print(String(currentStrategyIndex + 1) + "/" + String(strategies.count) + " - Testing strategy '" + strategy.cmdArgsLine + "'")
#endif
        SBDTestController.testStrategy(strategy, config: config, taskDomains: taskDomains, totalDomainsCount: totalDomainsCount, totalDomainRequestsCount: totalDomainRequestsCount, cancelTkSource: cancelTkSource) { result in
            do {
                let scan = try result.get()
                closureStrategiesScanRes.append(scan)
            } catch {
                print(error)
            }
            if (currentStrategyIndex + 1 == strategies.count) {
                //All strategies tested -> recurse exit
                _ = ByeDPI.stop()
                SBDTestController.notifyNoTestingStrategy()
                closureStrategiesScanRes.sort { a, b in
                    return a.successDomainRequestsCount > b.successDomainRequestsCount
                }
                completion(.success(closureStrategiesScanRes))
                return
            }
            SBDTestController.notifyProgressUpdate(testedStrategiesCount: currentStrategyIndex + 2, totalStrategiesCount: strategies.count)
            SBDTestController.testRecurse(currentStrategyIndex: currentStrategyIndex + 1, config: config, totalDomainsCount: totalDomainsCount, totalDomainRequestsCount: totalDomainRequestsCount, strategiesScanRes: &closureStrategiesScanRes, taskDomains: taskDomains, strategies: strategies, cancelTkSource: cancelTkSource, completion: completion)
        }
    }
    
    /// Checks the strategy trough multiple workers-threads
    /// - Parameters:
    ///   - strategy: Testing strategy
    ///   - config: ByeDPI test config
    ///   - taskDomains: Domains for workers-threads
    ///   - totalDomainsCount: Total domains count
    ///   - totalDomainRequestsCount: Total requests to domains count
    ///   - cancellationToken: Thread-safe cancellation token
    ///   - completion: Strategy test result completion handler
    private static func testStrategy(_ strategy: SBDStrategy, config: SBDTestConfig, taskDomains: [[String]], totalDomainsCount: Int, totalDomainRequestsCount: Int, cancelTkSource: ConcurrentCancellationTokenSource, completion: @escaping (_ result: Result<SBDStrategyTestResult, SBDError>) -> Void) {
        if (Thread.current.isCancelled || cancelTkSource.cancellationToken.cancellationRequested) {
            _ = ByeDPI.stop()
            //Cancelled with current values
            notifyNoTestingStrategy()
            completion(.failure(.general(errCode: -1, desc: "Strategy " + String(strategy.id) + " testing has been canceled")))
            return
        }
        let byeDPIConfig = strategy.generateConfig()
        _ = ByeDPI.stop()
        ByeDPI.start(args: byeDPIConfig.args) { err in
            print(err)
        }
        
        let testedDomainsIncrementor = ConcurrentIncrementor()
        let totalSuccessRequestsIncrementor = ConcurrentIncrementor()
        let totalFailRequestsIncrementor = ConcurrentIncrementor()

        let domainsScanResult = ConcurrentDomainsTestResultDictionary()
        
        let finishedTasksIncrementor = ConcurrentIncrementor()
        let strategyTestFinishSemaphore = DispatchSemaphore(value: 0)
        for i in 0...taskDomains.count - 1 {
            DispatchQueue.global().async {
                let socksProxySession = SBDURLSessionUtil.initSocksProxySession(addr: byeDPIConfig.listenIP, port: byeDPIConfig.listenPort, timeoutIntervalForResourceInS: UInt16(config.domainAnswerTimeoutInS), ephemeral: true)
                var strategyScanResult: [String: SBDDomainTestResult] = [:]
                for domain in taskDomains[i] {
                    if (Thread.current.isCancelled || cancelTkSource.cancellationToken.cancellationRequested) {
                        break
                    }
                    let domainScanResult = SBDTestController.testDomainSync(domain, proxySession: socksProxySession, strategy: strategy, requestsCount: config.domainRequestsCount, answerTimeoutInS: config.domainAnswerTimeoutInS, delayBetweenRequestsInS: config.delayBetweenRequestsInS, cancelTkSource: cancelTkSource)

                    strategyScanResult[domain] = domainScanResult
                    domainsScanResult.setValue(domainScanResult, forKey: domain)
                    testedDomainsIncrementor.increment()
                    totalSuccessRequestsIncrementor.increment(plusVal: Int(domainScanResult.successRequestsCount))
                    totalFailRequestsIncrementor.increment(plusVal: Int(domainScanResult.failedRequestsCount))

                    SBDTestController.notifyTestingStrategyDomainsUpdate(strategy, testedDomainsCount: testedDomainsIncrementor.get(), totalDomainsCount: totalDomainsCount)
                    SBDTestController.notifyTestingStrategyProgressUpdate(strategy, successDomainRequestsCount: totalSuccessRequestsIncrementor.get(), failDomainRequestsCount: totalFailRequestsIncrementor.get(), totalDomainRequestsCount: totalDomainRequestsCount)
                }
                               
                finishedTasksIncrementor.increment()
                let finsihedCount = finishedTasksIncrementor.get()
                #if DEBUG
                print("Dispatch worker #" + String(i) + " finish. Remains active dispatch workers - " + String(taskDomains.count - finsihedCount))
                #endif 
                if (finsihedCount == config.parallelRequestsCount) {
                    #if DEBUG
                    print("All dispatch workers finish")
                    #endif
                    strategyTestFinishSemaphore.signal()
                }
            }
        }
        _ = strategyTestFinishSemaphore.wait(timeout: .distantFuture)
        _ = ByeDPI.stop()
        let scanRes = SBDStrategyTestResult(strategy: strategy, domainsTestResult: domainsScanResult.threadSafeSnapshot)
        SBDTestController.notifyTestedStrategy(testResult: scanRes)
        completion(.success(scanRes))
    }
    
    /// Synchronously checks the single domain
    /// - Parameters:
    ///   - domain: Domain name
    ///   - proxySession: URL session with SOCKS5 proxy settings
    ///   - strategy: Testing strategy
    ///   - requestsCount: Requests to domain through ByeDPI
    ///   - answerTimeoutInS: Response wait timeout in seconds
    ///   - delayBetweenRequestsInS: Delay between the next request in seconds
    ///   - cancellationToken: Thread-safe cancellation token
    /// - Returns: Domain test result for the strategy
    private static func testDomainSync(_ domain: String, proxySession: URLSession, strategy: SBDStrategy, requestsCount: UInt8, answerTimeoutInS: UInt8, delayBetweenRequestsInS: UInt8, cancelTkSource: ConcurrentCancellationTokenSource) -> SBDDomainTestResult {
        var validatedDomain = domain
        if (!validatedDomain.hasPrefix("http")) {
            validatedDomain = "https://" + validatedDomain
        }
        guard let safeDomainUrl = URL(string: validatedDomain) else {
            return SBDDomainTestResult(domain: domain, successRequestsCount: 0, failedRequestsCount: requestsCount)
        }
        var success: UInt8 = 0
        var fail: UInt8 = 0
        
        let successIncrementor = ConcurrentIncrementor()
        let failIncrementor = ConcurrentIncrementor()
        
        for i in 0..<requestsCount {
            if (Thread.current.isCancelled || cancelTkSource.cancellationToken.cancellationRequested) {
                var successThreadSafe: UInt8 = 0
                successThreadSafe = UInt8(successIncrementor.get())
                return SBDDomainTestResult(domain: domain, successRequestsCount: successThreadSafe, failedRequestsCount: requestsCount - successThreadSafe)
            }
            #if DEBUG
            print("Testing domain '" + domain + "' availability - " + String(i + 1) + "/" + String(requestsCount))
            #endif          
            let semaphore = DispatchSemaphore(value: 0)
            let urlReq = URLRequest(url: safeDomainUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeInterval(answerTimeoutInS))
            let task = proxySession.dataTask(with: urlReq) { responseData, urlResponse, err in
                if let _ = responseData {
                    successIncrementor.increment()
                } else {
                    failIncrementor.increment()
                }
                semaphore.signal()
            }
            task.resume()
            /*while (Thread.current.isExecuting && !cancellationToken.cancellationRequested && task.response == nil && task.error == nil) {
                if let _ = task.response {
                    break
                }
                if let _ = task.error {
                    break
                }
                if (cancellationToken.cancellationRequested || Thread.current.isCancelled || Thread.current.isFinished) {
                    break
                }
                sleep(1)
            }*/
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            if let httpResponse = task.response as? HTTPURLResponse {
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    success += 1
                } else if let safeContentLength = httpResponse.allHeaderFields["Content-Length"] as? String, !safeContentLength.isEmpty {
                    success += 1
                } else {
                    fail += 1
                }
            } else {
                fail += 1
            }
            notifyTestingDomainProgressUpdate(domain, strategyID: strategy.id, successRequestsCount: success, failRequestsCount: fail, totalRequestsCount: Int(requestsCount))
            if (delayBetweenRequestsInS == 0 || cancelTkSource.cancellationToken.cancellationRequested) {
                continue
            }
            sleep(UInt32(delayBetweenRequestsInS))
        }
        var successThreadSafe: UInt8 = 0
        var failThreadSafe: UInt8 = 0

        successThreadSafe = UInt8(successIncrementor.get())
        failThreadSafe = UInt8(failIncrementor.get())
        if (success != successThreadSafe) {
            print("Test domain '" + domain + "'  warning: Success checks thread-safe value != 'Success' HTTPResponse checks value")
        }
        if (fail != failThreadSafe) {
            print("Test domain '" + domain + "'  warning: Fail checks thread-safe value != 'Fail' HTTPResponse checks value")
        }
        if (fail + success != requestsCount) {
            print("Test domain '" + domain + "'  warning: 'Success' and 'Fail' HTTPResponse count != Total requests count. Trying to correct by thread-safe values")
            if (successThreadSafe + successThreadSafe == requestsCount) {
                fail = failThreadSafe
                success = successThreadSafe
            }
        }
        let testRes = SBDDomainTestResult(domain: domain, successRequestsCount: success, failedRequestsCount: fail)
        
        SBDTestController.notifyTestedStrategyDomain(strategy, testResult: testRes)
        return testRes
    }
    
    /// Calculates total requests to all domains count during the check
    /// - Parameters:
    ///   - config: Test config, which contains 'requests count to single domain' parameter
    ///   - domainLists: Total domains count
    /// - Returns: Total requests to all domains count
    public static func calculateTotalRequestsCount(config: SBDTestConfig, domainLists: [SBDDomainList]) -> Int {
        let domains = config.retrieveDomains(domainLists: domainLists)
        return calculateTotalRequestsCount(domainRequestsCount: Int(config.domainRequestsCount), domainsCount: domains.count)
    }
    
    /// Calculates total requests to all domains count during the check
    /// - Parameters:
    ///   - domainRequestsCount: Requests count to single domain
    ///   - domainsCount: Total domains count
    /// - Returns: Total requests to all domains count
    public static func calculateTotalRequestsCount(domainRequestsCount: Int, domainsCount: Int) -> Int {
        return domainRequestsCount * domainsCount
    }
}

// Async extension
#if swift(>=5.5)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension SBDTestController {
    
    /// Test strategies asynchronously
    /// - Parameters:
    ///   - config: ByeDPI test config
    ///   - domainLists: Domain lists for retrieving test domains
    ///   - strategyLists: Strategy lists for retrieving test strategies
    public func test(config: SBDTestConfig, domainLists: [SBDDomainList], strategyLists: [SBDStrategyList]) async -> Result<[SBDStrategyTestResult], SBDError> {
        if (testingInProgress) {
#if DEBUG
            print("Another test in progress")
#endif
            return .failure(.general(errCode: -1, desc: "Another test in progress"))
        }
        if (config.domainListIDs.isEmpty) {
#if DEBUG
            print("Domain list array is empty")
#endif
            return .failure(.general(errCode: -1, desc: "Test config domain list IDs array is empty"))
        }
        let domains = SBDDomainController.retrieveSortedDomains(config.retrieveDomains(domainLists: domainLists))
        if (config.strategyListIDs.isEmpty) {
#if DEBUG
            print("Strategy list array is empty")
#endif
            return .failure(.general(errCode: -1, desc: "Test config strategy list IDs array is empty"))
        }
        let strategies = SBDStrategyController.retrieveSortedStrategies(config.retrieveStrategies(strategyLists: strategyLists))
        return await test(config: config, domains: domains, strategies: strategies)
    }
    
    /// Test strategies asynchronously
    /// - Parameters:
    ///   - config: ByeDPI test config
    ///   - domains: Domains for testing
    ///   - strategies: Strategies for testing
    public func test(config: SBDTestConfig, domains: [String], strategies: [SBDStrategy]) async -> Result<[SBDStrategyTestResult], SBDError> {
        if (testingInProgress) {
#if DEBUG
            print("Another test in progress")
#endif
            return .failure(.general(errCode: -1, desc: "Another test in progress"))
        }
        if (domains.isEmpty) {
#if DEBUG
            print("No domains for test")
#endif
            return .failure(.general(errCode: -1, desc: "No domains retrieved from config"))
        }
        if (strategies.isEmpty) {
#if DEBUG
            print("No strategies for test")
#endif
            return .failure(.general(errCode: -1, desc: "No strategies retrieved from config"))
        }
        var taskDomains: [[String]] = [[String]].init(repeating: [], count: Int(config.parallelRequestsCount))
        var taskI = 0
        for domain in domains {
            taskDomains[taskI % taskDomains.count].append(domain)
            taskI += 1
        }
        let cancelTkSource = ConcurrentCancellationTokenSource()
        _testThreadCancelTkSource = cancelTkSource
        _ = ByeDPI.stop()
        let totalDomainRequestsCount = SBDTestController.calculateTotalRequestsCount(domainRequestsCount: Int(config.domainRequestsCount), domainsCount: domains.count)
        var strategiesScanRes: [SBDStrategyTestResult] = []
        SBDTestController.notifyProgressUpdate(testedStrategiesCount: 1, totalStrategiesCount: strategies.count)
        for i in 0..<strategies.count {
            if (cancelTkSource.cancellationToken.cancellationRequested) {
                if (strategiesScanRes.isEmpty) {
                    //No strategies scanned at all
                    _ = ByeDPI.stop()
                    notifyNoTestingStrategy()
                    return .failure(.general(errCode: -1, desc: "Strategy scan cancel"))
                }
                //Fill non-scanned strategies as 'failed'
                var emptyDomainsScanRes: [String: SBDDomainTestResult] = [:]
                for domains in taskDomains {
                    for domain in domains {
                        emptyDomainsScanRes[domain] = SBDDomainTestResult(domain: domain, successRequestsCount: 0, failedRequestsCount: config.domainRequestsCount)
                    }
                }
                var counter = i
                while (counter < strategies.count) {
                    strategiesScanRes.append(SBDStrategyTestResult(strategy: strategies[counter], domainsTestResult: emptyDomainsScanRes))
                    counter += 1
                }
                break
            }
            let strategy = strategies[i]
            SBDTestController.notifyTestingStrategyUpdate(strategy)
    #if DEBUG
            print(String(i + 1) + "/" + String(strategies.count) + " - Testing strategy '" + strategy.cmdArgsLine + "'")
    #endif
            let testRes = await SBDTestController.testStrategy(strategy, config: config, taskDomains: taskDomains, totalDomainsCount: domains.count, totalDomainRequestsCount: totalDomainRequestsCount, cancelTkSource: cancelTkSource)
            do {
                let scan = try testRes.get()
                strategiesScanRes.append(scan)
            } catch {
                print(error)
            }
            SBDTestController.notifyProgressUpdate(testedStrategiesCount: i + 2, totalStrategiesCount: strategies.count)
        }
        _ = ByeDPI.stop()
        SBDTestController.notifyNoTestingStrategy()
        strategiesScanRes.sort { a, b in
            return a.successDomainRequestsCount > b.successDomainRequestsCount
        }
        return .success(strategiesScanRes)
    }
    
    /// Checks the strategy trough multiple workers-threads asynchronously
    /// - Parameters:
    ///   - strategy: Testing strategy
    ///   - config: ByeDPI test config
    ///   - taskDomains: Domains for workers-threads
    ///   - totalDomainsCount: Total domains count
    ///   - totalDomainRequestsCount: Total requests to domains count
    private static func testStrategy(_ strategy: SBDStrategy, config: SBDTestConfig, taskDomains: [[String]], totalDomainsCount: Int, totalDomainRequestsCount: Int, cancelTkSource: ConcurrentCancellationTokenSource) async -> Result<SBDStrategyTestResult, SBDError> {
        let byeDPIConfig = strategy.generateConfig()
        _ = ByeDPI.stop()
        if let launchErr = await ByeDPI.start(args: byeDPIConfig.args) {
            return .failure(.general(errCode: -1, desc: launchErr.errorDescription))
        }
        
        var domainsScanResult: [String: SBDDomainTestResult] = [:]
        var err: SBDError? = nil
        await withThrowingTaskGroup(of: [SBDDomainTestResult].self) { group in
            let testedDomainsIncrementor = ConcurrentIncrementor()
            let totalSuccessRequestsIncrementor = ConcurrentIncrementor()
            let totalFailRequestsIncrementor = ConcurrentIncrementor()
            for i in 0..<taskDomains.count {
                group.addTask {
                    let socksProxySession = SBDURLSessionUtil.initSocksProxySession(addr: byeDPIConfig.listenIP, port: byeDPIConfig.listenPort, timeoutIntervalForResourceInS: UInt16(config.domainAnswerTimeoutInS), ephemeral: true)
                    var taskScanResult: [SBDDomainTestResult] = []
                    for domain in taskDomains[i] {
                        if (cancelTkSource.cancellationToken.cancellationRequested) {
                            break
                        }
                        let scanRes = await testDomain(domain, proxySession: socksProxySession, strategy: strategy, requestsCount: config.domainRequestsCount, answerTimeoutInS: config.domainAnswerTimeoutInS, delayBetweenRequestsInS: config.delayBetweenRequestsInS, cancelTkSource: cancelTkSource)
                        
                        taskScanResult.append(scanRes)
                        testedDomainsIncrementor.increment()
                        totalSuccessRequestsIncrementor.increment(plusVal: Int(scanRes.successRequestsCount))
                        totalFailRequestsIncrementor.increment(plusVal: Int(scanRes.failedRequestsCount))
                        SBDTestController.notifyTestingStrategyDomainsUpdate(strategy, testedDomainsCount: testedDomainsIncrementor.get(), totalDomainsCount: totalDomainsCount)
                        SBDTestController.notifyTestingStrategyProgressUpdate(strategy, successDomainRequestsCount: totalSuccessRequestsIncrementor.get(), failDomainRequestsCount: totalFailRequestsIncrementor.get(), totalDomainRequestsCount: totalDomainRequestsCount)
                    }
#if DEBUG
                    print("Dispatch worker #" + String(i) + " finish")
#endif
                    return taskScanResult
                }
            }
            
            do {
                for try await taskScanResult in group {
                    for scanRes in taskScanResult {
                        domainsScanResult[scanRes.domain] = scanRes
                    }
                }
            } catch {
#if DEBUG
                print("Task result retrieve fail")
                print(error)
#endif
                err = SBDError.general(errCode: -1, desc: error.localizedDescription)
            }
        }
        if let safeErr = err {
            return .failure(safeErr)
        }
        _ = ByeDPI.stop()
        let scanRes = SBDStrategyTestResult(strategy: strategy, domainsTestResult: domainsScanResult)
        SBDTestController.notifyTestedStrategy(testResult: scanRes)
        return .success(scanRes)
    }
    
    /// Checks the single domain asynchronously
    /// - Parameters:
    ///   - domain: Domain name
    ///   - proxySession: URL session with SOCKS5 proxy settings
    ///   - strategy: Testing strategy
    ///   - requestsCount: Requests to domain through ByeDPI
    ///   - answerTimeoutInS: Response wait timeout in seconds
    ///   - delayBetweenRequestsInS: Delay between the next request in seconds
    /// - Returns: Domain test result for the strategy
    private static func testDomain(_ domain: String, proxySession: URLSession, strategy: SBDStrategy, requestsCount: UInt8, answerTimeoutInS: UInt8, delayBetweenRequestsInS: UInt8, cancelTkSource: ConcurrentCancellationTokenSource) async -> SBDDomainTestResult {
        var validatedDomain = domain
        if (!validatedDomain.hasPrefix("http")) {
            validatedDomain = "https://" + validatedDomain
        }
        guard let safeDomainUrl = URL(string: validatedDomain) else {
            return SBDDomainTestResult(domain: domain, successRequestsCount: 0, failedRequestsCount: requestsCount)
        }
        var success: UInt8 = 0
        var fail: UInt8 = 0
        
        for i in 0..<requestsCount {
            if (cancelTkSource.cancellationToken.cancellationRequested) {
                fail = requestsCount - success
                break
            }
            #if DEBUG
            print("Testing domain '" + domain + "' availability - " + String(i + 1) + "/" + String(requestsCount))
            #endif
            let urlReq = URLRequest(url: safeDomainUrl, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeInterval(answerTimeoutInS))
            do {
                let response = try await proxySession.data(for: urlReq)
                if (!response.0.isEmpty) {
                    success += 1
                } else if let httpResponse = response.1 as? HTTPURLResponse {
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                        success += 1
                    } else if let safeContentLength = httpResponse.allHeaderFields["Content-Length"] as? String, !safeContentLength.isEmpty {
                        success += 1
                    } else {
                        fail += 1
                    }
                } else {
                    fail += 1
                }
            } catch {
                fail += 1
            }
            notifyTestingDomainProgressUpdate(domain, strategyID: strategy.id, successRequestsCount: success, failRequestsCount: fail, totalRequestsCount: Int(requestsCount))
            if (delayBetweenRequestsInS == 0 || cancelTkSource.cancellationToken.cancellationRequested) {
                continue
            }
            let sleepTask = Task {
                let nanos = UInt64(delayBetweenRequestsInS) * 1_000_000_000
                try? await Task.sleep(nanoseconds: nanos)
                return 0
            }
            _ = await sleepTask.value
        }
        let testRes = SBDDomainTestResult(domain: domain, successRequestsCount: success, failedRequestsCount: fail)
        
        SBDTestController.notifyTestedStrategyDomain(strategy, testResult: testRes)
        return testRes
    }
}
#endif

extension SBDTestController {
    
    fileprivate func notifyProgressUpdate(testedStrategiesCount: Int, totalStrategiesCount: Int) {
        SBDTestController.notifyProgressUpdate(testedStrategiesCount: testedStrategiesCount, totalStrategiesCount: totalStrategiesCount)
    }
    
    fileprivate static func notifyProgressUpdate(testedStrategiesCount: Int, totalStrategiesCount: Int) {
        let notification = Notification(name: .SBDTestingProgressUpdate, userInfo: [
            "tested": testedStrategiesCount,
            "total": totalStrategiesCount
        ])
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
    
    fileprivate func notifyTestingStrategyUpdate(_ strategy: SBDStrategy) {
        SBDTestController.notifyTestingStrategyUpdate(strategy)
    }

    fileprivate static func notifyTestingStrategyUpdate(_ strategy: SBDStrategy) {
        let notification = Notification(name: .SBDTestingStrategyUpdate, object: nil, userInfo: [
            "strategy": strategy
        ])
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
    
    fileprivate func notifyNoTestingStrategy() {
        SBDTestController.notifyNoTestingStrategy()
    }
    
    fileprivate static func notifyNoTestingStrategy() {
        let notification = Notification(name: .SBDNoTestingStrategy)
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
    
    fileprivate func notifyTestingStrategyProgressUpdate(_ strategy: SBDStrategy, successDomainRequestsCount: Int, failDomainRequestsCount: Int, totalDomainRequestsCount: Int) {
        SBDTestController.notifyTestingStrategyProgressUpdate(strategy, successDomainRequestsCount: successDomainRequestsCount, failDomainRequestsCount: failDomainRequestsCount, totalDomainRequestsCount: totalDomainRequestsCount)
    }

    fileprivate static func notifyTestingStrategyProgressUpdate(_ strategy: SBDStrategy, successDomainRequestsCount: Int, failDomainRequestsCount: Int, totalDomainRequestsCount: Int) {
        let notification = Notification(name: .SBDTestingStrategyProgressUpdate, object: strategy.id, userInfo: [
            "successDomainRequestsCount": successDomainRequestsCount,
            "failDomainRequestsCount": failDomainRequestsCount,
            "totalDomainRequestsCount": totalDomainRequestsCount,
        ])
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
    
    fileprivate func notifyTestingStrategyDomainsUpdate(_ strategy: SBDStrategy, testedDomainsCount: Int, totalDomainsCount: Int) {
        SBDTestController.notifyTestingStrategyDomainsUpdate(strategy, testedDomainsCount: testedDomainsCount, totalDomainsCount: totalDomainsCount)
    }

    fileprivate static func notifyTestingStrategyDomainsUpdate(_ strategy: SBDStrategy, testedDomainsCount: Int, totalDomainsCount: Int) {
        let notification = Notification(name: .SBDTestingStrategyDomainsProgressUpdate, object: strategy.id, userInfo: [
            "tested": testedDomainsCount,
            "total": totalDomainsCount
        ])
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
    
    fileprivate func notifyTestingDomainProgressUpdate(_ domain: String, strategyID: Int, successRequestsCount: UInt8, failRequestsCount: UInt8, totalRequestsCount: Int) {
        SBDTestController.notifyTestingDomainProgressUpdate(domain, strategyID: strategyID, successRequestsCount: successRequestsCount, failRequestsCount: failRequestsCount, totalRequestsCount: totalRequestsCount)
    }

    fileprivate static func notifyTestingDomainProgressUpdate(_ domain: String, strategyID: Int, successRequestsCount: UInt8, failRequestsCount: UInt8, totalRequestsCount: Int) {
        let strategyDomainLink = SBDDomainStrategyLink(strategyID: strategyID, domain: domain)
        let notification = Notification(name: .SBDTestingDomainProgress, object: strategyDomainLink.linkID, userInfo: [
            "success": successRequestsCount,
            "fail": failRequestsCount,
            "tested": Int(successRequestsCount + failRequestsCount),
            "total": totalRequestsCount
        ])
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
    
    fileprivate func notifyTestedStrategy(testResult: SBDStrategyTestResult) {
        SBDTestController.notifyTestedStrategy(testResult: testResult)
    }

    fileprivate static func notifyTestedStrategy(testResult: SBDStrategyTestResult) {
        let notification = Notification(name: .SBDTestedStrategy, object: nil, userInfo: [
            "result": testResult
        ])
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
    
    fileprivate func notifyTestedStrategyDomain(_ strategy: SBDStrategy, testResult: SBDDomainTestResult) {
        SBDTestController.notifyTestedStrategyDomain(strategy, testResult: testResult)
    }
    
    fileprivate static func notifyTestedStrategyDomain(_ strategy: SBDStrategy, testResult: SBDDomainTestResult) {
        let notification = Notification(name: .SBDTestedStrategyDomain, object: strategy.id, userInfo: [
            "result": testResult
        ])
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
}

/// Thread-safe domains test dictionary
fileprivate final class ConcurrentDomainsTestResultDictionary: @unchecked Sendable {
    private var value: [String: SBDDomainTestResult]
    private let queue: DispatchQueue
    
    fileprivate var threadSafeSnapshot: [String: SBDDomainTestResult] {
        get {
            return queue.sync {
                var res: [String: SBDDomainTestResult] = [:]
                for entry in value {
                    res[entry.key] = entry.value
                }
                return res
            }
        }
    }
    
    fileprivate var count: Int {
        get {
            return queue.sync {
                return value.count
            }
        }
    }
    
    fileprivate var isEmpty: Bool {
        get {
            return queue.sync {
                return value.isEmpty
            }
        }
    }
    
    fileprivate var keys: [String] {
        get {
            return queue.sync {
                return Array(value.keys)
            }
        }
        
    }
    
    fileprivate var values: [SBDDomainTestResult] {
        get {
            return queue.sync {
                return Array(value.values)
            }
        }
    }
    
    fileprivate init() {
        value = [:]
        queue = DispatchQueue(label: "org.zeit.byedpi.domain-scans")
    }
    
    fileprivate func value(forKey key: String) -> SBDDomainTestResult? {
        return queue.sync { value[key] }
    }
    
    public func forEach(_ body: (String, SBDDomainTestResult) throws -> Void) rethrows {
        let snapshot = queue.sync { value }
        try snapshot.forEach(body)
    }
    
    fileprivate func setValue(_ value: SBDDomainTestResult?, forKey key: String) {
        queue.sync(flags: .barrier) { self.value[key] = value }
    }
    
    @discardableResult
    public func updateValue(_ value: SBDDomainTestResult, forKey key: String) -> SBDDomainTestResult? {
        return queue.sync(flags: .barrier) {
            let old = self.value[key]
            self.value[key] = value
            return old
        }
    }
    
    @discardableResult
    fileprivate func removeValue(forKey key: String) -> SBDDomainTestResult? {
        return queue.sync(flags: .barrier) { value.removeValue(forKey: key) }
    }
    
    fileprivate func removeAll() {
        queue.sync(flags: .barrier) { value.removeAll() }
    }
    
    fileprivate subscript(key: String) -> SBDDomainTestResult? {
        get {
            return queue.sync { value[key] }
        }
        set {
            queue.sync(flags: .barrier) { value[key] = newValue }
        }
    }
}

/// Thread-safe general-purpose incrementor
fileprivate final class ConcurrentIncrementor: @unchecked Sendable {
    
    /// Integer raw value
    private var value: Int
    /// Dispatch queue
    private let queue = DispatchQueue(label: "org.zeit.byedpi.incrementor")

    init(initialValue: Int = 0) {
        self.value = initialValue
    }

    /// Increments the value
    /// - Parameter plusVal: Increments count. Default value is 1
    func increment(plusVal: Int = 1) {
        if (plusVal <= 0) {
            return
        }
        queue.sync {
            value += plusVal
        }
    }

    /// Retrieves the value (thread-safe)
    func get() -> Int {
        return queue.sync { value }
    }
}
