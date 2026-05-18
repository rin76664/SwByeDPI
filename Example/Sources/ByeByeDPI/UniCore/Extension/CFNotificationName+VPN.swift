//
//  CFNotification+Name.swift
//  SwByeDPI
//
//  Created by developer on 02.04.2026.
//

import CoreFoundation

extension CFNotificationName {
    
    fileprivate static let byeDPIVpnStartedKey = "byeDPIVpnStarted"
    fileprivate static let byeDPIVpnStoppedKey = "byeDPIVpnStopped"
    
    static let byeDPIVpnStarted = CFNotificationName(byeDPIVpnStartedKey as CFString)
    
    static let byeDPIVpnStopped = CFNotificationName(byeDPIVpnStoppedKey as CFString)
    
}
