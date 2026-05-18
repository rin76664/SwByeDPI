//
//  Global+ThreadSleep.swift
//  ByeDPITests
//
//  Created by developer on 24.04.2026.
//
#if os(Android)
import Foundation

/// Android global func sleep through Thread.sleep
/// - Parameter __seconds: Sleep interval in seconds
@discardableResult
func sleep(_ __seconds: UInt32) -> UInt32 {
    let nowTs = Date().timeIntervalSince1970
    Thread.sleep(forTimeInterval: TimeInterval(__seconds))
    return __seconds - UInt32(Date().timeIntervalSince1970 - nowTs)
}
#endif
