//
//  MacMonitorApp.swift
//  MacMonitor
//
//  Created on 2026-02-06.
//

import SwiftUI

@main
struct MacMonitorApp: App {
    @StateObject private var deviceDiscovery = DeviceDiscoveryViewModel()
    @StateObject private var monitorViewModel = MonitorViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deviceDiscovery)
                .environmentObject(monitorViewModel)
                .preferredColorScheme(.none) // Respect system settings
        }
    }
}
