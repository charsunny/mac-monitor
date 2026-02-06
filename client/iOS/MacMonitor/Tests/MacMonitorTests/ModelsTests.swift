import XCTest
@testable import MacMonitor

final class ModelsTests: XCTestCase {
    
    // MARK: - Device Tests
    
    func testDeviceInitialization() {
        let device = Device(
            id: "test-1",
            name: "Test Device",
            host: "192.168.1.100",
            port: 8080
        )
        
        XCTAssertEqual(device.id, "test-1")
        XCTAssertEqual(device.name, "Test Device")
        XCTAssertEqual(device.host, "192.168.1.100")
        XCTAssertEqual(device.port, 8080)
    }
    
    func testDeviceBaseURL() {
        let device = Device(
            id: "test-1",
            name: "Test Device",
            host: "192.168.1.100",
            port: 8080
        )
        
        XCTAssertEqual(device.baseURL, "http://192.168.1.100:8080")
    }
    
    func testDeviceEquality() {
        let device1 = Device(id: "test-1", name: "Device 1", host: "192.168.1.1", port: 8080)
        let device2 = Device(id: "test-1", name: "Device 1", host: "192.168.1.1", port: 8080)
        let device3 = Device(id: "test-2", name: "Device 2", host: "192.168.1.2", port: 8080)
        
        XCTAssertEqual(device1, device2)
        XCTAssertNotEqual(device1, device3)
    }
    
    func testDeviceEncoding() throws {
        let device = Device(
            id: "test-1",
            name: "Test Device",
            host: "192.168.1.100",
            port: 8080
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(device)
        
        XCTAssertNotNil(data)
        XCTAssertTrue(data.count > 0)
    }
    
    func testDeviceDecoding() throws {
        let json = """
        {
            "id": "test-1",
            "name": "Test Device",
            "host": "192.168.1.100",
            "port": 8080
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let device = try decoder.decode(Device.self, from: json)
        
        XCTAssertEqual(device.id, "test-1")
        XCTAssertEqual(device.name, "Test Device")
        XCTAssertEqual(device.host, "192.168.1.100")
        XCTAssertEqual(device.port, 8080)
    }
    
    // MARK: - SystemInfo Tests
    
    func testSystemInfoDecoding() throws {
        let json = """
        {
            "hostname": "MacBook-Pro",
            "osVersion": "14.0",
            "model": "MacBookPro18,1",
            "architecture": "arm64"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let info = try decoder.decode(SystemInfo.self, from: json)
        
        XCTAssertEqual(info.hostname, "MacBook-Pro")
        XCTAssertEqual(info.osVersion, "14.0")
        XCTAssertEqual(info.model, "MacBookPro18,1")
        XCTAssertEqual(info.architecture, "arm64")
    }
    
    // MARK: - CPUInfo Tests
    
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
    
    func testCPUInfoDecodingWithNilValues() throws {
        let json = """
        {
            "usage": 0.45,
            "coreCount": 8
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let cpuInfo = try decoder.decode(CPUInfo.self, from: json)
        
        XCTAssertEqual(cpuInfo.usage, 0.45)
        XCTAssertEqual(cpuInfo.coreCount, 8)
        XCTAssertNil(cpuInfo.frequency)
        XCTAssertNil(cpuInfo.temperature)
    }
    
    // MARK: - MemoryInfo Tests
    
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
        
        XCTAssertEqual(memoryInfo.total, 16000000000)
        XCTAssertEqual(memoryInfo.used, 8000000000)
        XCTAssertEqual(memoryInfo.free, 8000000000)
        XCTAssertEqual(memoryInfo.pressure, 0.5)
    }
    
    // MARK: - DiskInfo Tests
    
    func testDiskInfoDecoding() throws {
        let json = """
        {
            "total": 500000000000,
            "used": 250000000000,
            "free": 250000000000
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let diskInfo = try decoder.decode(DiskInfo.self, from: json)
        
        XCTAssertEqual(diskInfo.total, 500000000000)
        XCTAssertEqual(diskInfo.used, 250000000000)
        XCTAssertEqual(diskInfo.free, 250000000000)
    }
    
    // MARK: - NetworkInfo Tests
    
    func testNetworkInfoDecoding() throws {
        let json = """
        {
            "bytesIn": 1000,
            "bytesOut": 2000,
            "packetsIn": 10,
            "packetsOut": 20
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let networkInfo = try decoder.decode(NetworkInfo.self, from: json)
        
        XCTAssertEqual(networkInfo.bytesIn, 1000)
        XCTAssertEqual(networkInfo.bytesOut, 2000)
        XCTAssertEqual(networkInfo.packetsIn, 10)
        XCTAssertEqual(networkInfo.packetsOut, 20)
    }
    
    // MARK: - SystemStatus Tests
    
    func testSystemStatusDecoding() throws {
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
        let status = try decoder.decode(SystemStatus.self, from: json)
        
        XCTAssertEqual(status.timestamp, "2024-01-01T00:00:00Z")
        XCTAssertEqual(status.cpu.usage, 0.5)
        XCTAssertEqual(status.memory.total, 16000000000)
        XCTAssertEqual(status.disk.total, 500000000000)
        XCTAssertEqual(status.network.bytesIn, 1000)
        XCTAssertEqual(status.temperature, 45.0)
        XCTAssertEqual(status.uptime, 3600.0)
        XCTAssertEqual(status.processCount, 100)
        XCTAssertEqual(status.threadCount, 500)
        XCTAssertEqual(status.batteryLevel, 0.8)
        XCTAssertEqual(status.isCharging, true)
    }
    
    func testSystemStatusDecodingWithOptionalValues() throws {
        let json = """
        {
            "timestamp": "2024-01-01T00:00:00Z",
            "cpu": {
                "usage": 0.5,
                "coreCount": 8
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
            "uptime": 3600.0,
            "processCount": 100,
            "threadCount": 500
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let status = try decoder.decode(SystemStatus.self, from: json)
        
        XCTAssertNil(status.temperature)
        XCTAssertNil(status.batteryLevel)
        XCTAssertNil(status.isCharging)
    }
    
    // MARK: - HealthStatus Tests
    
    func testHealthStatusDecoding() throws {
        let json = """
        {
            "status": "ok"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let health = try decoder.decode(HealthStatus.self, from: json)
        
        XCTAssertEqual(health.status, "ok")
    }
}
