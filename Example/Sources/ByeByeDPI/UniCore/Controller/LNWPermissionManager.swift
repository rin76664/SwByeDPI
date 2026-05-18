//
//  LNWPermissionManager.swift
//  SwByeDPI
//
//  Created by developer on 06.03.2026.
//

import Foundation
import Network

class LNWPermissionManager: ObservableObject {
    
    @Published fileprivate(set) var authorizationStatus: LNWAuthorizationStatus
    
    init() {
        authorizationStatus = .notDetermined
    }
    
    func checkAndRequestPermission(completion: @escaping (LNWAuthorizationStatus) -> Void) {
        
        // Attempt to connect to a dummy local IP address and port
        // This IP should ideally be unreachable to quickly trigger the 'waiting' state.
        let connection = NWConnection(host: NWEndpoint.Host("example.local"), port: NWEndpoint.Port(65000), using: .tcp)
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                // Connection became ready (unexpected for dummy IP, but means access granted)
                self?.authorizationStatus = .granted
                completion(.granted)
                break
            case .waiting(let error):
                if case let .posix(code) = error {
                    if (code.rawValue == 89) /* EOPNOTSUPP */ {
                        // The 'waiting' state with certain errors often indicates a policy denial
                        self?.authorizationStatus = .denied
                        completion(.denied)
                    }
                    self?.authorizationStatus = .notDetermined
                    completion(.notDetermined)
                    break
                } else if case let .dns(code) = error {
                    if (code == -65570) { // kDNSServiceErr_PolicyDenied
                        // The 'waiting' state with certain errors often indicates a policy denial
                        self?.authorizationStatus = .denied
                        completion(.denied)
                    }
                    return
                } else {
                    return
                }
            case .failed(let error):
                // The kDNSServiceErr_PolicyDenied error can also manifest here
                let nsError = error as NSError
                if nsError.domain == "kDNSServiceErrorDomain" && (nsError.code == -65554 || nsError.code == -65570) { // kDNSServiceErr_PolicyDenied
                    self?.authorizationStatus = .denied
                    completion(.denied)
                    break
                } else {
                    // Consider it potentially granted if it failed for another reason
                    self?.authorizationStatus = .granted
                    completion(.granted)
                    break
                }
            case .setup, .cancelled, .preparing:
                return
            @unknown default:
                return
            }
            connection.cancel()
        }
           
        connection.start(queue: .main)
    }
}
