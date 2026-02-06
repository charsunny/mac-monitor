#if os(macOS)
import Foundation
import AppKit

/// Menu bar application for displaying system monitoring information
class MenuBarApp: NSObject {
    private var statusItem: NSStatusItem?
    private let monitor: SystemMonitor
    private var timer: Timer?
    private var menu: NSMenu?
    
    init(monitor: SystemMonitor) {
        self.monitor = monitor
        super.init()
    }
    
    func start() {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else {
            print("❌ Failed to create status bar button")
            return
        }
        
        button.title = "🖥️"
        
        // Create menu
        menu = NSMenu()
        
        // Add menu items
        updateMenu()
        
        statusItem?.menu = menu
        
        // Start update timer (update every 5 seconds)
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateMenu()
        }
        
        print("✅ Menu bar app started")
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        statusItem = nil
        print("⏹️ Menu bar app stopped")
    }
    
    private func updateMenu() {
        guard let menu = menu else { return }
        
        menu.removeAllItems()
        
        // Get system status
        let status = monitor.getStatus()
        
        // Title
        let titleItem = NSMenuItem(title: "Mac Monitor", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // CPU
        let cpuPercent = Int(status.cpu.usage * 100)
        let cpuItem = NSMenuItem(title: "CPU: \(cpuPercent)% (\(status.cpu.coreCount) cores)", action: nil, keyEquivalent: "")
        cpuItem.isEnabled = false
        menu.addItem(cpuItem)
        
        // Memory
        let totalGB = Double(status.memory.total) / 1_073_741_824.0
        let usedGB = Double(status.memory.used) / 1_073_741_824.0
        let pressurePercent = Int(status.memory.pressure * 100)
        let memoryItem = NSMenuItem(title: String(format: "Memory: %.1f/%.1f GB (%d%%)", usedGB, totalGB, pressurePercent), action: nil, keyEquivalent: "")
        memoryItem.isEnabled = false
        menu.addItem(memoryItem)
        
        // Disk
        let diskTotalGB = Double(status.disk.total) / 1_073_741_824.0
        let diskUsedGB = Double(status.disk.used) / 1_073_741_824.0
        let diskUsagePercent = Int((Double(status.disk.used) / Double(status.disk.total)) * 100)
        let diskItem = NSMenuItem(title: String(format: "Disk: %.1f/%.1f GB (%d%%)", diskUsedGB, diskTotalGB, diskUsagePercent), action: nil, keyEquivalent: "")
        diskItem.isEnabled = false
        menu.addItem(diskItem)
        
        // Network
        let inMB = Double(status.network.bytesIn) / 1_048_576.0
        let outMB = Double(status.network.bytesOut) / 1_048_576.0
        let networkItem = NSMenuItem(title: String(format: "Network: ↓%.2f MB/s ↑%.2f MB/s", inMB, outMB), action: nil, keyEquivalent: "")
        networkItem.isEnabled = false
        menu.addItem(networkItem)
        
        // Uptime
        let hours = Int(status.uptime) / 3600
        let minutes = (Int(status.uptime) % 3600) / 60
        let uptimeItem = NSMenuItem(title: "Uptime: \(hours)h \(minutes)m", action: nil, keyEquivalent: "")
        uptimeItem.isEnabled = false
        menu.addItem(uptimeItem)
        
        // Processes
        let processItem = NSMenuItem(title: "Processes: \(status.processCount)", action: nil, keyEquivalent: "")
        processItem.isEnabled = false
        menu.addItem(processItem)
        
        // Battery (if available)
        if let batteryLevel = status.batteryLevel,
           let isCharging = status.isCharging {
            let batteryPercent = Int(batteryLevel * 100)
            let chargingStatus = isCharging ? "⚡" : ""
            let batteryItem = NSMenuItem(title: "Battery: \(batteryPercent)% \(chargingStatus)", action: nil, keyEquivalent: "")
            batteryItem.isEnabled = false
            menu.addItem(batteryItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Server status
        let serverItem = NSMenuItem(title: "Server: http://localhost:8080", action: nil, keyEquivalent: "")
        serverItem.isEnabled = false
        menu.addItem(serverItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
#endif
