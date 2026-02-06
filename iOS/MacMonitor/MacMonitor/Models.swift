//
//  Models.swift
//  MacMonitor
//
//  Created on 2026-02-06.
//

import Foundation

// MARK: - Device
struct Device: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let host: String
    let port: Int
    
    var baseURL: String {
        "http://\(host):\(port)"
    }
}

// MARK: - System Info
struct SystemInfo: Codable {
    let hostname: String
    let osVersion: String
    let model: String
    let architecture: String
}

// MARK: - System Status
struct SystemStatus: Codable {
    let timestamp: String
    let cpu: CPUInfo
    let memory: MemoryInfo
    let disk: DiskInfo
    let network: NetworkInfo
    let temperature: Double?
    let uptime: Double
    let processCount: Int
    let threadCount: Int
    let batteryLevel: Double?
    let isCharging: Bool?
}

struct CPUInfo: Codable {
    let usage: Double
    let coreCount: Int
    let frequency: Double?
    let temperature: Double?
}

struct MemoryInfo: Codable {
    let total: Int64
    let used: Int64
    let free: Int64
    let pressure: Double
}

struct DiskInfo: Codable {
    let total: Int64
    let used: Int64
    let free: Int64
}

struct NetworkInfo: Codable {
    let bytesIn: Int
    let bytesOut: Int
    let packetsIn: Int
    let packetsOut: Int
}

// MARK: - Health Check
struct HealthStatus: Codable {
    let status: String
}
