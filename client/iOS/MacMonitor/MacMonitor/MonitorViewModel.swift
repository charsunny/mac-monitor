//
//  MonitorViewModel.swift
//  MacMonitor
//
//  Created on 2026-02-06.
//

import Foundation
import Combine
import UserNotifications

class MonitorViewModel: ObservableObject {
    @Published var selectedDevice: Device?
    @Published var status: SystemStatus?
    @Published var systemInfo: SystemInfo?
    @Published var isConnected = false
    @Published var lastUpdateTime = "--"
    @Published var currentAlert: String?
    
    // Historical data for charts (keep last 30 data points)
    @Published var cpuHistory: [Double] = []
    @Published var memoryHistory: [Double] = []
    @Published var diskHistory: [Double] = []
    @Published var networkInHistory: [Double] = []
    @Published var networkOutHistory: [Double] = []
    @Published var temperatureHistory: [Double] = []
    private let maxHistoryCount = 30
    
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private let apiClient = APIClient()
    
    // Alert thresholds
    var cpuThreshold: Double = 0.8
    var memoryThreshold: Double = 0.8
    private var lastAlertTime: Date?
    private let alertCooldown: TimeInterval = 30 // seconds
    
    init() {
        loadSettings()
        requestNotificationPermissions()
    }
    
    func selectDevice(_ device: Device) {
        selectedDevice = device
        saveSettings()
        fetchSystemInfo()
        refreshData()
    }
    
    func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refreshData()
        }
        refreshData()
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func refreshData() {
        guard let device = selectedDevice else {
            isConnected = false
            return
        }
        
        apiClient.fetchStatus(from: device)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.isConnected = false
                }
            } receiveValue: { [weak self] status in
                self?.status = status
                self?.isConnected = true
                self?.updateLastUpdateTime()
                self?.updateHistoricalData(status: status)
                self?.checkAlerts()
            }
            .store(in: &cancellables)
    }
    
    func dismissAlert() {
        currentAlert = nil
    }
    
    private func fetchSystemInfo() {
        guard let device = selectedDevice else { return }
        
        apiClient.fetchInfo(from: device)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error fetching system info: \(error)")
                }
            } receiveValue: { [weak self] info in
                self?.systemInfo = info
            }
            .store(in: &cancellables)
    }
    
    private func updateLastUpdateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        lastUpdateTime = formatter.string(from: Date())
    }
    
    private func updateHistoricalData(status: SystemStatus) {
        // Update CPU history
        cpuHistory.append(status.cpu.usage)
        if cpuHistory.count > maxHistoryCount {
            cpuHistory.removeFirst()
        }
        
        // Update Memory history
        memoryHistory.append(status.memory.pressure)
        if memoryHistory.count > maxHistoryCount {
            memoryHistory.removeFirst()
        }
        
        // Update Disk history
        let diskUsage = status.disk.total > 0 ? Double(status.disk.used) / Double(status.disk.total) : 0
        diskHistory.append(diskUsage)
        if diskHistory.count > maxHistoryCount {
            diskHistory.removeFirst()
        }
        
        // Update Network history
        networkInHistory.append(Double(status.network.bytesIn))
        if networkInHistory.count > maxHistoryCount {
            networkInHistory.removeFirst()
        }
        
        networkOutHistory.append(Double(status.network.bytesOut))
        if networkOutHistory.count > maxHistoryCount {
            networkOutHistory.removeFirst()
        }
        
        // Update Temperature history (if available)
        if let temp = status.temperature {
            temperatureHistory.append(temp)
            if temperatureHistory.count > maxHistoryCount {
                temperatureHistory.removeFirst()
            }
        }
    }
    
    private func checkAlerts() {
        guard let status = status else { return }
        
        // Check cooldown
        if let lastAlert = lastAlertTime,
           Date().timeIntervalSince(lastAlert) < alertCooldown {
            return
        }
        
        var alerts: [String] = []
        
        // Check CPU
        if status.cpu.usage >= cpuThreshold {
            alerts.append("CPU 使用率过高: \(String(format: "%.1f%%", status.cpu.usage * 100))")
        }
        
        // Check Memory
        if status.memory.pressure >= memoryThreshold {
            alerts.append("内存使用率过高: \(String(format: "%.1f%%", status.memory.pressure * 100))")
        }
        
        if !alerts.isEmpty {
            let message = alerts.joined(separator: " | ")
            currentAlert = message
            lastAlertTime = Date()
            sendNotification(message: message)
        }
    }
    
    private func sendNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Mac Monitor 告警"
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "selectedDevice"),
           let device = try? JSONDecoder().decode(Device.self, from: data) {
            selectedDevice = device
        }
        
        cpuThreshold = UserDefaults.standard.double(forKey: "cpuThreshold")
        if cpuThreshold == 0 { cpuThreshold = 0.8 }
        
        memoryThreshold = UserDefaults.standard.double(forKey: "memoryThreshold")
        if memoryThreshold == 0 { memoryThreshold = 0.8 }
    }
    
    private func saveSettings() {
        if let device = selectedDevice,
           let data = try? JSONEncoder().encode(device) {
            UserDefaults.standard.set(data, forKey: "selectedDevice")
        }
    }
    
    func saveThresholds() {
        UserDefaults.standard.set(cpuThreshold, forKey: "cpuThreshold")
        UserDefaults.standard.set(memoryThreshold, forKey: "memoryThreshold")
    }
}
