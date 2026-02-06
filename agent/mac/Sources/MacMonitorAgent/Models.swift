import Foundation
import Hummingbird

// Response models for API endpoints

struct HealthResponse: Codable, ResponseEncodable {
    let status: String
}

struct SystemInfoResponse: Codable, ResponseEncodable {
    let hostname: String
    let osVersion: String
    let model: String
    let architecture: String
}

struct CPUInfo: Codable {
    let usage: Double
    let coreCount: Int
    let frequency: Double?
    let temperature: Double?
}

struct MemoryInfo: Codable {
    let total: UInt64
    let used: UInt64
    let free: UInt64
    let pressure: Double
}

struct DiskInfo: Codable {
    let total: UInt64
    let used: UInt64
    let free: UInt64
}

struct NetworkInfo: Codable {
    let bytesIn: Int
    let bytesOut: Int
    let packetsIn: UInt64
    let packetsOut: UInt64
}

struct SystemStatusResponse: Codable, ResponseEncodable {
    let timestamp: String
    let cpu: CPUInfo
    let memory: MemoryInfo
    let disk: DiskInfo
    let network: NetworkInfo
    let temperature: Double?
    let uptime: TimeInterval
    let processCount: Int
    let threadCount: Int
    let batteryLevel: Double?
    let isCharging: Bool?
}
