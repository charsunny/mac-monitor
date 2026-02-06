import XCTest
@testable import MacMonitorAgent

final class ModelsTests: XCTestCase {
    
    // MARK: - HealthResponse Tests
    
    func testHealthResponseEncoding() throws {
        let response = HealthResponse(status: "ok")
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        XCTAssertNotNil(data)
        XCTAssertTrue(data.count > 0)
    }
    
    func testHealthResponseDecoding() throws {
        let json = """
        {"status": "ok"}
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(HealthResponse.self, from: json)
        
        XCTAssertEqual(response.status, "ok")
    }
    
    // MARK: - SystemInfoResponse Tests
    
    func testSystemInfoResponseEncoding() throws {
        let response = SystemInfoResponse(
            hostname: "test-host",
            osVersion: "14.0",
            model: "Mac",
            architecture: "arm64"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        XCTAssertNotNil(data)
    }
    
    func testSystemInfoResponseDecoding() throws {
        let json = """
        {
            "hostname": "test-host",
            "osVersion": "14.0",
            "model": "Mac",
            "architecture": "arm64"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(SystemInfoResponse.self, from: json)
        
        XCTAssertEqual(response.hostname, "test-host")
        XCTAssertEqual(response.osVersion, "14.0")
    }
    
    // MARK: - CPUInfo Tests
    
    func testCPUInfoEncoding() throws {
        let cpuInfo = CPUInfo(
            usage: 0.45,
            coreCount: 8,
            frequency: 3.2,
            temperature: 45.5
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(cpuInfo)
        
        XCTAssertNotNil(data)
    }
    
    func testCPUInfoDecoding() throws {
        let json = """
        {
            "usage": 0.45,
            "coreCount": 8,
            "frequency": 3.2,
            "temperature": 45.5
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let cpuInfo = try decoder.decode(CPUInfo.self, from: json)
        
        XCTAssertEqual(cpuInfo.usage, 0.45)
        XCTAssertEqual(cpuInfo.coreCount, 8)
        XCTAssertEqual(cpuInfo.frequency, 3.2)
        XCTAssertEqual(cpuInfo.temperature, 45.5)
    }
    
    // MARK: - MemoryInfo Tests
    
    func testMemoryInfoEncoding() throws {
        let memoryInfo = MemoryInfo(
            total: 16_000_000_000,
            used: 8_000_000_000,
            free: 8_000_000_000,
            pressure: 0.5
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(memoryInfo)
        
        XCTAssertNotNil(data)
    }
    
    func testMemoryInfoDecoding() throws {
        let json = """
        {
            "total": 16000000000,
            "used": 8000000000,
            "free": 8000000000,
            "pressure": 0.5
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let memoryInfo = try decoder.decode(MemoryInfo.self, from: json)
        
        XCTAssertEqual(memoryInfo.total, 16_000_000_000)
        XCTAssertEqual(memoryInfo.used, 8_000_000_000)
        XCTAssertEqual(memoryInfo.pressure, 0.5)
    }
    
    // MARK: - DiskInfo Tests
    
    func testDiskInfoEncoding() throws {
        let diskInfo = DiskInfo(
            total: 500_000_000_000,
            used: 250_000_000_000,
            free: 250_000_000_000
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(diskInfo)
        
        XCTAssertNotNil(data)
    }
    
    // MARK: - NetworkInfo Tests
    
    func testNetworkInfoEncoding() throws {
        let networkInfo = NetworkInfo(
            bytesIn: 1000,
            bytesOut: 2000,
            packetsIn: 10,
            packetsOut: 20
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(networkInfo)
        
        XCTAssertNotNil(data)
    }
    
    // MARK: - SystemStatusResponse Tests
    
    func testSystemStatusResponseEncoding() throws {
        let response = SystemStatusResponse(
            timestamp: "2024-01-01T00:00:00Z",
            cpu: CPUInfo(usage: 0.5, coreCount: 8, frequency: 3.2, temperature: 45.0),
            memory: MemoryInfo(total: 16_000_000_000, used: 8_000_000_000, free: 8_000_000_000, pressure: 0.5),
            disk: DiskInfo(total: 500_000_000_000, used: 250_000_000_000, free: 250_000_000_000),
            network: NetworkInfo(bytesIn: 1000, bytesOut: 2000, packetsIn: 10, packetsOut: 20),
            temperature: 45.0,
            uptime: 3600.0,
            processCount: 100,
            threadCount: 500,
            batteryLevel: 0.8,
            isCharging: true
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        XCTAssertNotNil(data)
        XCTAssertTrue(data.count > 0)
    }
    
    func testSystemStatusResponseDecoding() throws {
        let json = """
        {
            "timestamp": "2024-01-01T00:00:00Z",
            "cpu": {
                "usage": 0.5,
                "coreCount": 8,
                "frequency": 3.2,
                "temperature": 45.0
            },
            "memory": {
                "total": 16000000000,
                "used": 8000000000,
                "free": 8000000000,
                "pressure": 0.5
            },
            "disk": {
                "total": 500000000000,
                "used": 250000000000,
                "free": 250000000000
            },
            "network": {
                "bytesIn": 1000,
                "bytesOut": 2000,
                "packetsIn": 10,
                "packetsOut": 20
            },
            "temperature": 45.0,
            "uptime": 3600.0,
            "processCount": 100,
            "threadCount": 500,
            "batteryLevel": 0.8,
            "isCharging": true
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(SystemStatusResponse.self, from: json)
        
        XCTAssertEqual(response.timestamp, "2024-01-01T00:00:00Z")
        XCTAssertEqual(response.cpu.usage, 0.5)
        XCTAssertEqual(response.uptime, 3600.0)
        XCTAssertEqual(response.batteryLevel, 0.8)
    }
}
