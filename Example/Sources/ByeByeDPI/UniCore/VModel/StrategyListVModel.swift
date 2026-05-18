//
//  DomainListVModel.swift
//  SwByeDPI
//
//  Created by developer on 11.03.2026.
//

import SwiftUI
import SwByeDPI

class StrategyListVModel: ObservableObject {
    
    fileprivate static let briefStrategiesCount = 3
    
    var id: String {
        get {
            return SBDStrategyList.retrieveIDFromName(name)
        }
    }
    
    @Published fileprivate(set) var name: String
    
    @Published fileprivate(set) var strategies: Set<SBDStrategy>
    
    @Published fileprivate(set) var briefStrategies: [SBDStrategy]
    
    var strategiesCountFormattedInfo: String {
        get {
            var res = R.string.localizable.settingsStrategiesCountPrefix() + " - "
            res += String(strategies.count)
            return res
        }
    }
    
    var sortedStrategies: [SBDStrategy] {
        get {
            var res = [SBDStrategy].init(strategies)
            res.sort { a, b in
                return a.id > b.id
            }
            return res
        }
    }
    
    init(list: SBDStrategyList) {
        name = list.name
        strategies = Set<SBDStrategy>(list.strategies)
        briefStrategies = []
        refreshBriefStrategies()
    }
    
    func rename(_ name: String) {
        self.name = name
    }
    
    func updateStrategies(_ strategies: Set<SBDStrategy>) {
        self.strategies = Set<SBDStrategy>(strategies)
        refreshBriefStrategies()
    }
    
    fileprivate func refreshBriefStrategies() {
        var i = 0
        let sorted = sortedStrategies
        var res: [SBDStrategy] = []
        while (i < StrategyListVModel.briefStrategiesCount && i < strategies.count) {
            res.append(sorted[i])
            i += 1
        }
        briefStrategies = res
    }
}
