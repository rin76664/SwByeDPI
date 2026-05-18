//
//  ContentView.swift
//  ByeDPI-iOS
//
//  Created by developer on 24.02.2026.
//

import SwiftUI
import SwByeDPI

struct HomeScreen: View {
    
    private enum AlertType: UInt8, Identifiable {
        case proxyEnabledHint
        case proxyStartError
        
        var id: UInt8 {
            get {
                return self.rawValue
            }
        }
    }
    
    @EnvironmentObject fileprivate var properties: AppProperties
    @EnvironmentObject fileprivate var lnwPermissionManager: LNWPermissionManager
    
    @State var proxyEnabled = false
    @State var proxyStartFailErrorText = ""
    @State private var showAlertType: AlertType? = nil
    {
        didSet {
            if (showAlertType == nil) {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: DispatchTimeInterval.seconds(3))) {
                if (showAlertType == nil) {
                    return
                }
                showAlertType = nil
            }
        }
    }
    
    fileprivate var byeDPIProxyAddr: String {
        get {
            return properties.byeDPILaunchConfig.listenIP + ":" + String(properties.byeDPILaunchConfig.listenPort)
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8.0) {
            Spacer(minLength: 16)
            Button {
                toggleVpn()
            } label: {
                Image(R.image.icPower)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
            }
            .frame(width: 120, height: 120, alignment: .center)
            .background(Color(proxyEnabled
                              ? R.color.grPositive
                              : R.color.grAccent))
            .cornerRadius(120)
            Text(proxyEnabled ? R.string.localizable.homeVpnStateOn : R.string.localizable.homeVpnStateOff)
                .foregroundColor(Color(R.color.grSecondary))
                .font(.caption)
                .fontWeight(.semibold)
            Text(byeDPIProxyAddr)
                .foregroundColor(Color(R.color.grSecondary))
                .font(.headline)
                .fontWeight(.semibold)
            Spacer(minLength: 16)
            if (proxyEnabled) {
                Button {
                    if (showAlertType == .proxyEnabledHint) {
                        return
                    }
                    showAlertType = .proxyEnabledHint
                } label: {
                    Text(R.string.localizable.generalSettings)
                }
                .padding(EdgeInsets(top: .zero, leading: 16.0, bottom: 12.0, trailing: 16.0))
            } else {
                NavigationLink {
                    SettingsScreen()
                } label: {
                    Text(R.string.localizable.generalSettings)
                }
                .padding(EdgeInsets(top: .zero, leading: 16.0, bottom: 12.0, trailing: 16.0))
            }
        }
        .alert(isPresented: Binding(get: {
            return showAlertType != nil
        }, set: { newVal in
            if (newVal) {
                return
            }
            showAlertType = nil
        }), content: {
            if (!proxyStartFailErrorText.isEmpty) {
                return Alert(title: Text(R.string.localizable.homeStartByeDPIErrTitle), message: Text(proxyStartFailErrorText))
            }
            return Alert(title: Text(R.string.localizable.homeSettingsAccessHint))
        })
    }
    
    fileprivate func toggleVpn() {
#if DEBUG
        if (ProcessInfo.processInfo.previewMode) {
            if (proxyEnabled) {
                proxyStartFailErrorText = "Preview error text"
                showAlertType = .proxyStartError
                proxyEnabled = false
                return
            }
            proxyStartFailErrorText = ""
            proxyEnabled = true
            return
        }
#endif
        proxyStartFailErrorText = ""
        if (proxyEnabled) {
            _ = ByeDPI.stop()
            proxyEnabled = false
            return
        }
        if (properties.byeDPILaunchConfig.listenIP == "0.0.0.0") {
            lnwPermissionManager.checkAndRequestPermission { status in
                print(status)
            }
        }
        let args = properties.byeDPILaunchConfig.args
        proxyEnabled = true
        ByeDPI.start(args: args) { startErr in
            self.proxyEnabled = false
            self.proxyStartFailErrorText = startErr.errorDescription
            self.showAlertType = .proxyStartError
            _ = ByeDPI.stop()
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        HomeScreen()
    }
    .environmentObject(previewProperties)
    .environmentObject(previewLnwPermissionManager)
    .environmentObject(previewDomainsManager)
    .environmentObject(previewStrategiesManager)
    .environmentObject(previewByeDPIManager)
    .environmentObject(previewTestManager)
}
#endif
