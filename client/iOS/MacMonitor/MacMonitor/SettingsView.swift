//
//  SettingsView.swift
//  MacMonitor
//
//  Created on 2026-02-06.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var cpuThreshold: Double
    @State private var memoryThreshold: Double
    
    init() {
        _cpuThreshold = State(initialValue: 80.0)
        _memoryThreshold = State(initialValue: 80.0)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("告警阈值")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("CPU 告警阈值")
                            Spacer()
                            Text("\(Int(cpuThreshold))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $cpuThreshold, in: 50...100, step: 5)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("内存告警阈值")
                            Spacer()
                            Text("\(Int(memoryThreshold))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $memoryThreshold, in: 50...100, step: 5)
                    }
                }
                
                Section(header: Text("刷新设置")) {
                    HStack {
                        Text("自动刷新间隔")
                        Spacer()
                        Text("5 秒")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    if let info = monitorViewModel.systemInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            DetailRow(label: "主机名", value: info.hostname)
                            DetailRow(label: "系统版本", value: info.osVersion)
                            DetailRow(label: "架构", value: info.architecture)
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            cpuThreshold = monitorViewModel.cpuThreshold * 100
            memoryThreshold = monitorViewModel.memoryThreshold * 100
        }
    }
    
    private func saveSettings() {
        monitorViewModel.cpuThreshold = cpuThreshold / 100
        monitorViewModel.memoryThreshold = memoryThreshold / 100
        monitorViewModel.saveThresholds()
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MonitorViewModel())
}
