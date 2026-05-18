//
//  CFNotification+Name.swift
//  SwByeDPI
//
//  Created by developer on 02.04.2026.
//

import Foundation

extension Notification.Name {
    
    fileprivate static let byeDPIVpnStartedKey = "byeDPIVpnStarted"
    fileprivate static let byeDPIVpnStoppedKey = "byeDPIVpnStopped"
    
    static let BBDVpnStarted = Notification.Name(byeDPIVpnStartedKey)
    
    static let BBDVpnStopped = Notification.Name(byeDPIVpnStoppedKey)
    
}
