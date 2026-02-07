//
//  ContentView.swift
//  MacMonitor
//
//  Created on 2026-02-06.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var deviceDiscovery: DeviceDiscoveryViewModel
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showSettings = false
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: 0) {
                // Header
                HeaderView(showSettings: $showSettings)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                
                // Alert Banner
                if let alert = monitorViewModel.currentAlert {
                    AlertBanner(message: alert)
                        .transition(.move(edge: .top))
                }
                
                // Dashboard Grid
                if isLandscape {
                    // Landscape: 3x2 grid - no scrolling needed
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        dashboardCards
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                } else {
                    // Portrait: 2x3 grid with scroll
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            dashboardCards
                        }
                        .padding()
                    }
                }
                
                // Footer
                FooterView()
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(monitorViewModel)
        }
        .onAppear {
            deviceDiscovery.startDiscovery()
            monitorViewModel.startAutoRefresh()
        }
        .onDisappear {
            deviceDiscovery.stopDiscovery()
            monitorViewModel.stopAutoRefresh()
        }
    }
    
    @ViewBuilder
    private var dashboardCards: some View {
        CPUCardView()
        MemoryCardView()
        DiskCardView()
        NetworkCardView()
        TemperatureCardView()
        ProcessCardView()
    }
}

struct HeaderView: View {
    @EnvironmentObject var deviceDiscovery: DeviceDiscoveryViewModel
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("🖥️ Mac Monitor")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    Text(monitorViewModel.selectedDevice?.name ?? "未连接")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Circle()
                        .fill(monitorViewModel.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
            
            // Device Picker
            Menu {
                ForEach(deviceDiscovery.discoveredDevices) { device in
                    Button(action: {
                        monitorViewModel.selectDevice(device)
                    }) {
                        HStack {
                            Text(device.name)
                            if monitorViewModel.selectedDevice?.id == device.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                
                if deviceDiscovery.discoveredDevices.isEmpty {
                    Text("未发现设备")
                        .foregroundColor(.secondary)
                }
            } label: {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            
            Button(action: {
                monitorViewModel.refreshData()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
        }
    }
}

struct FooterView: View {
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    
    var body: some View {
        HStack {
            Text("最后更新: \(monitorViewModel.lastUpdateTime)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                Text("自动刷新: 5秒")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
    }
}

struct AlertBanner: View {
    let message: String
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    
    var body: some View {
        HStack {
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                monitorViewModel.dismissAlert()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.orange)
    }
}

#Preview {
    ContentView()
        .environmentObject(DeviceDiscoveryViewModel())
        .environmentObject(MonitorViewModel())
}
