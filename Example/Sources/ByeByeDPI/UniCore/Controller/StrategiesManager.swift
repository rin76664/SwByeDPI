//
//  StrategiesManager.swift
//  SwByeDPI
//
//  Created by developer on 06.03.2026.
//

import SwiftUI
import SwByeDPI

class StrategiesManager: ObservableObject {
    
    fileprivate static let _strategiesStorageFilename = Constants.PSEUDO_BUNDLE_ID + ".strategies"

    let controller: SBDStrategyListController
    
    @Published fileprivate(set) var lists: [SBDStrategyList]
    
#if DEBUG
    init(lists: [SBDStrategyList]) {
        controller = SBDStrategyListController()
        self.lists = []
        NotificationCenter.default.addObserver(forName: controller.itemListsCollectionUpdateEvent, object: nil, queue: .main, using: onItemsCollectionUpdate)
        controller.addListItems(lists)
    }
#endif

    init() {
        controller = SBDStrategyListController()
        lists = StrategiesManager.loadSortedLists()
        controller.addListItems(lists)
        NotificationCenter.default.addObserver(forName: controller.itemListsCollectionUpdateEvent, object: nil, queue: .main, using: onItemsCollectionUpdate)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: controller.itemListsCollectionUpdateEvent, object: nil)
    }
    
    fileprivate func onItemsCollectionUpdate(_ notification: Notification) {
        let parseRes = notification.tryParseStrategyListsFromNotification()
        guard let updDict = parseRes.1 else {
            return
        }
        lists = SBDStrategyListController.retrieveSortedStrategyLists(updDict)
        StrategiesManager.saveSortedLists(lists)
    }
    
    /// Export sorted strategy lists to property list
    fileprivate static func saveSortedLists(_ lists: [SBDStrategyList]) {
        if (PlistUtil.savePropertyList(lists, filename: StrategiesManager._strategiesStorageFilename)) {
            return
        }
#if DEBUG
            print("Strategy lists not saved")
#endif
    }
    
    /// Load sorted strategy lists from property list
    fileprivate static func loadSortedLists() -> [SBDStrategyList] {
        guard let parsedLists: [SBDStrategyList] = PlistUtil.parsePropertyList(filename: StrategiesManager._strategiesStorageFilename) else {
            return []
        }
        return parsedLists
    }
}
