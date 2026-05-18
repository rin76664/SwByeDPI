//
//  NEUtil.swift
//  SwByeDPI
//
//  Created by developer on 26.03.2026.
//

import Foundation

final class NEUtil {
    
    static func generateConnectionParamsFromAppUserDefaults() -> [String: NSObject] {
        var res: [String: NSObject] = [
            UserDefaultsAppKeys.selectedByeDPIListenIpAddrKey.rawValue: UserDefaultsAppProperties.byeDPIListenIp as NSObject,
            UserDefaultsAppKeys.selectedByeDPIListenPortKey.rawValue: UserDefaultsAppProperties.byeDPIListenPort as NSObject,
            UserDefaultsAppKeys.selectedByeDPIBufSizeKey.rawValue: UserDefaultsAppProperties.byeDPIBufSize as NSObject,
            UserDefaultsAppKeys.byeDPIRestrictDomainResolve.rawValue: UserDefaultsAppProperties.byeDPIRestrictDomainResolve as NSObject,
            UserDefaultsAppKeys.byeDPIRestrictUDP.rawValue: UserDefaultsAppProperties.byeDPIRestrictUDP as NSObject,
            UserDefaultsAppKeys.selectedByeDPICmdArgsKey.rawValue: UserDefaultsAppProperties.byeDPICmdArgs as NSObject,
            UserDefaultsAppKeys.selectedDnsOverAddrKey.rawValue: UserDefaultsAppProperties.dnsOverAddr as NSObject,
            UserDefaultsAppKeys.resolvedDnsServersKey.rawValue: UserDefaultsAppProperties.resolvedDnsServers as NSObject,
            UserDefaultsAppKeys.selectedTunMtuKey.rawValue: UserDefaultsAppProperties.tunMtu as NSObject,
        ]
        if let safeTtl = UserDefaultsAppProperties.byeDPITTL {
            res[UserDefaultsAppKeys.selectedByeDPITTL.rawValue] = safeTtl as NSObject
        }
        if let safeLogLevel = UserDefaultsAppProperties.byeDPILogLevel {
            res[UserDefaultsAppKeys.selectedbyeDPILogLevel.rawValue] = safeLogLevel as NSObject
        }
        return res
    }
}
