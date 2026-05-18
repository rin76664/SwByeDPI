//
//  Socks5Tunnel+Async.swift
//  SwByeDPI
//
//  Created by developer on 30.03.2026.
//

import Foundation
@preconcurrency import Tun2SocksKit

extension Socks5Tunnel {
    
    static var _hevSocksThread: Thread?
    
    static func run(with config: Socks5Tunnel.Config) async -> Int32 {
        var opCode: Int32 = 0
        let thread = Thread {
            let startRes = Socks5Tunnel.run(withConfig: config)
            if (startRes != 0) {
                //Invalid config -> sync return -> update opCode (concurrency unsafe)
                opCode = startRes
            }
        }
        thread.name = "Tun2Socks(hev-socks5-tunnel)"
        _hevSocksThread = thread
        thread.start()
        let sleepTask = Task {
            let oneSecInNanos: UInt64 = 1_000_000_000
            try? await Task.sleep(nanoseconds: oneSecInNanos)
            return 0
        }
        _ = await sleepTask.value
        return opCode
    }
    
    static func stop() {
        _hevSocksThread?.cancel()
        _hevSocksThread = nil
        Socks5Tunnel.quit()
    }
    
}
