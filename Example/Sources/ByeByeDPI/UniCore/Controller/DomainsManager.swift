//
//  DomainsController.swift
//  SwByeDPI
//
//  Created by developer on 06.03.2026.
//

import SwiftUI
import SwByeDPI

class DomainsManager: ObservableObject {
    
    fileprivate static let _domainsStorageFilename = Constants.PSEUDO_BUNDLE_ID + ".domains"

    /// Domain list controller
    let controller: SBDDomainListController
    
    /// Sorted domain lists
    @Published fileprivate(set) var lists: [SBDDomainList]
    
#if DEBUG
    init(lists: [SBDDomainList]) {
        controller = SBDDomainListController()
        self.lists = []
        NotificationCenter.default.addObserver(forName: controller.itemListsCollectionUpdateEvent, object: nil, queue: .main, using: onItemsCollectionUpdate)
        controller.addListItems(lists)
    }
#endif

    init() {
        controller = SBDDomainListController()
        lists = DomainsManager.loadSortedLists()
        controller.addListItems(lists)
        NotificationCenter.default.addObserver(forName: controller.itemListsCollectionUpdateEvent, object: nil, queue: .main, using: onItemsCollectionUpdate)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: controller.itemListsCollectionUpdateEvent, object: nil)
    }
    
    fileprivate func onItemsCollectionUpdate(_ notification: Notification) {
        let parseRes = notification.tryParseDomainListsFromNotification()
        guard let updDict = parseRes.1 else {
            return
        }
        lists = SBDDomainListController.retrieveSortedDomainLists(updDict)
        DomainsManager.saveSortedLists(lists)
    }
    
    /// Export sorted domain lists to property list
    fileprivate static func saveSortedLists(_ lists: [SBDDomainList]) {
        if (PlistUtil.savePropertyList(lists, filename: DomainsManager._domainsStorageFilename)) {
            return
        }
#if DEBUG
            print("Domain lists not saved")
#endif
    }
    
    /// Load sorted domain lists from property list
    fileprivate static func loadSortedLists() -> [SBDDomainList] {
        guard let parsedLists: [SBDDomainList] = PlistUtil.parsePropertyList(filename: DomainsManager._domainsStorageFilename) else {
            return []
        }
        return parsedLists
    }
}
