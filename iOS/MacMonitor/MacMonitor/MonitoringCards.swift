//
//  MonitoringCards.swift
//  MacMonitor
//
//  Created on 2026-02-06.
//

import SwiftUI

// MARK: - CPU Card
struct CPUCardView: View {
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    
    var body: some View {
        MonitorCardView(
            title: "💻 CPU",
            value: String(format: "%.1f%%", monitorViewModel.status?.cpu.usage ?? 0),
            details: [
                ("核心数", "\(monitorViewModel.status?.cpu.coreCount ?? 0)"),
                ("频率", String(format: "%.1f GHz", monitorViewModel.status?.cpu.frequency ?? 0))
            ],
            progress: (monitorViewModel.status?.cpu.usage ?? 0) / 100.0,
            lastUpdate: monitorViewModel.lastUpdateTime
        )
    }
}

// MARK: - Memory Card
struct MemoryCardView: View {
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    
    var body: some View {
        let used = monitorViewModel.status?.memory.used ?? 0
        let total = monitorViewModel.status?.memory.total ?? 0
        let pressure = monitorViewModel.status?.memory.pressure ?? 0
        
        return MonitorCardView(
            title: "🧠 内存",
            value: String(format: "%.1f%%", pressure * 100),
            details: [
                ("已使用", formatBytes(used)),
                ("总容量", formatBytes(total))
            ],
            progress: pressure,
            lastUpdate: monitorViewModel.lastUpdateTime
        )
    }
}

// MARK: - Disk Card
struct DiskCardView: View {
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    
    var body: some View {
        let used = monitorViewModel.status?.disk.used ?? 0
        let total = monitorViewModel.status?.disk.total ?? 0
        let free = monitorViewModel.status?.disk.free ?? 0
        let usage = total > 0 ? Double(used) / Double(total) : 0
        
        return MonitorCardView(
            title: "💾 磁盘",
            value: String(format: "%.1f%%", usage * 100),
            details: [
                ("已使用", formatBytes(used)),
                ("可用", formatBytes(free))
            ],
            progress: usage,
            lastUpdate: monitorViewModel.lastUpdateTime
        )
    }
}

// MARK: - Network Card
struct NetworkCardView: View {
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    
    var body: some View {
        let bytesIn = monitorViewModel.status?.network.bytesIn ?? 0
        let bytesOut = monitorViewModel.status?.network.bytesOut ?? 0
        let packetsIn = monitorViewModel.status?.network.packetsIn ?? 0
        let packetsOut = monitorViewModel.status?.network.packetsOut ?? 0
        
        return MonitorCardView(
            title: "🌐 网络",
            value: "",
            customContent: AnyView(
                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        VStack {
                            Text(formatBytesPerSecond(bytesIn))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("↓ 下载")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text(formatBytesPerSecond(bytesOut))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("↑ 上传")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("接收包数")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatNumber(packetsIn))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("发送包数")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatNumber(packetsOut))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            ),
            details: [],
            progress: nil,
            lastUpdate: monitorViewModel.lastUpdateTime
        )
    }
}

// MARK: - Temperature Card
struct TemperatureCardView: View {
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    
    var body: some View {
        let temp = monitorViewModel.status?.temperature
        let batteryLevel = monitorViewModel.status?.batteryLevel
        let isCharging = monitorViewModel.status?.isCharging
        
        return MonitorCardView(
            title: "🌡️ 温度",
            value: temp != nil ? String(format: "%.1f°C", temp!) : "N/A",
            details: [
                ("电池电量", batteryLevel != nil ? String(format: "%.0f%%", batteryLevel! * 100) : "N/A"),
                ("充电状态", isCharging != nil ? (isCharging! ? "充电中" : "未充电") : "N/A")
            ],
            progress: nil,
            lastUpdate: monitorViewModel.lastUpdateTime
        )
    }
}

// MARK: - Process Card
struct ProcessCardView: View {
    @EnvironmentObject var monitorViewModel: MonitorViewModel
    
    var body: some View {
        let processCount = monitorViewModel.status?.processCount ?? 0
        let threadCount = monitorViewModel.status?.threadCount ?? 0
        let uptime = monitorViewModel.status?.uptime ?? 0
        
        return MonitorCardView(
            title: "⚙️ 进程",
            value: "\(processCount)",
            details: [
                ("线程数", "\(threadCount)"),
                ("运行时间", formatUptime(uptime))
            ],
            progress: nil,
            lastUpdate: monitorViewModel.lastUpdateTime
        )
    }
}

// MARK: - Generic Monitor Card
struct MonitorCardView: View {
    let title: String
    let value: String
    var customContent: AnyView?
    let details: [(String, String)]
    let progress: Double?
    let lastUpdate: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text(lastUpdate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Main content
            if let customContent = customContent {
                customContent
            } else {
                VStack(spacing: 8) {
                    Text(value)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: progressColor(progress ?? 0),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text(title.contains("CPU") ? "使用率" : 
                         title.contains("内存") ? "使用率" :
                         title.contains("磁盘") ? "使用率" :
                         title.contains("进程") ? "进程数" : "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Details
            if !details.isEmpty {
                HStack(spacing: 8) {
                    ForEach(details.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(details[index].0)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(details[index].1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Progress bar
            if let progress = progress {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: progressColor(progress),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * min(progress, 1.0))
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private func progressColor(_ value: Double) -> [Color] {
        if value >= 0.9 {
            return [.red, .orange]
        } else if value >= 0.7 {
            return [.orange, .yellow]
        } else {
            return [.blue, .purple]
        }
    }
}

// MARK: - Utility Functions
func formatBytes(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .binary
    formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
    return formatter.string(fromByteCount: bytes)
}

func formatBytesPerSecond(_ bytes: Int) -> String {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .binary
    formatter.allowedUnits = [.useKB, .useMB, .useGB]
    return formatter.string(fromByteCount: Int64(bytes)) + "/s"
}

func formatNumber(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
}

func formatUptime(_ seconds: Double) -> String {
    let days = Int(seconds) / 86400
    let hours = (Int(seconds) % 86400) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    
    if days > 0 {
        return "\(days)天 \(hours)时"
    } else if hours > 0 {
        return "\(hours)时 \(minutes)分"
    } else {
        return "\(minutes)分"
    }
}
