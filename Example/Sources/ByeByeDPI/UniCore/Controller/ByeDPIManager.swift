//
//  ByeDPIManager.swift
//  SwByeDPI
//
//  Created by developer on 06.03.2026.
//

import Foundation
import SwByeDPI

class ByeDPIManager: ObservableObject {
    
    @Published var dpiRuning: Bool
    
    init() {
        dpiRuning = ByeDPI.proxyStarted
    }
    
    func refreshDpiRunningState() -> Bool {
        dpiRuning = ByeDPI.proxyStarted
        return dpiRuning
    }
    
    func startDPI(config: SBDConfig) {
        if (ByeDPI.proxyStarted) {
            _ = ByeDPI.stop()
        }
        dpiRuning = true
        ByeDPI.start(args: config.args) { dpiStartErr in
            self.dpiRuning = false
            print(dpiStartErr)
        }
    }
    
    func stopDPI() {
        _ = ByeDPI.stop()
    }
}
