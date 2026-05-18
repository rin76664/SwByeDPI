//
//  DomainListVModel.swift
//  SwByeDPI
//
//  Created by developer on 11.03.2026.
//

import SwiftUI
import SwByeDPI

class DomainListVModel: ObservableObject {
    
    fileprivate static let briefDomainsCount = 4
    
    var id: String {
        get {
            return SBDDomainList.retrieveIDFromName(name)
        }
    }
    
    @Published fileprivate(set) var name: String
    
    @Published fileprivate(set) var domains: Set<String>
    
    @Published fileprivate(set) var briefDomains: [String]
    
    var domainsCountFormattedInfo: String {
        get {
            var res = R.string.localizable.settingsDomainsCountPrefix() + " - "
            res += String(domains.count)
            return res
        }
    }
    
    var sortedDomains: [String] {
        get {
            var res = [String].init(domains)
            res.sort { a, b in
                return a.compare(b) == .orderedDescending
            }
            return res
        }
    }
    
    init(list: SBDDomainList) {
        name = list.name
        domains = Set<String>(list.domains)
        briefDomains = []
        refreshBriefDomains()
    }
    
    func rename(_ name: String) {
        self.name = name
    }
    
    func updateDomains(_ domains: Set<String>) {
        self.domains = Set<String>(domains)
        refreshBriefDomains()
    }
    
    fileprivate func refreshBriefDomains() {
        var i = 0
        let sorted = sortedDomains
        var res: [String] = []
        while (i < DomainListVModel.briefDomainsCount && i < domains.count) {
            res.append(sorted[i])
            i += 1
        }
        briefDomains = res
    }
}
