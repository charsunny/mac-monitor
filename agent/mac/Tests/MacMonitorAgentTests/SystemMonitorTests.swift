import XCTest
@testable import MacMonitorAgent

final class SystemMonitorTests: XCTestCase {
    
    var systemMonitor: SystemMonitor!
    
    override func setUp() {
        super.setUp()
        systemMonitor = SystemMonitor()
    }
    
    override func tearDown() {
        systemMonitor = nil
        super.tearDown()
    }
    
    // MARK: - CPU Info Tests
    
    func testGetCPUInfo() {
        let cpuInfo = systemMonitor.getCPUInfo()
        
        // Verify basic properties
        XCTAssertGreaterThanOrEqual(cpuInfo.usage, 0.0, "CPU usage should be non-negative")
        XCTAssertLessThanOrEqual(cpuInfo.usage, 1.0, "CPU usage should not exceed 100%")
        XCTAssertGreaterThan(cpuInfo.coreCount, 0, "Core count should be positive")
    }
    
    func testGetCPUInfoCoreCount() {
        let cpuInfo = systemMonitor.getCPUInfo()
        let expectedCoreCount = ProcessInfo.processInfo.activeProcessorCount
        
        XCTAssertEqual(cpuInfo.coreCount, expectedCoreCount, "Core count should match system processor count")
    }
    
    func testGetCPUInfoConsistency() {
        let cpuInfo1 = systemMonitor.getCPUInfo()
        let cpuInfo2 = systemMonitor.getCPUInfo()
        
        // Core count should be consistent
        XCTAssertEqual(cpuInfo1.coreCount, cpuInfo2.coreCount, "Core count should remain consistent")
    }
    
    // MARK: - Memory Info Tests
    
    func testGetMemoryInfo() {
        let memoryInfo = systemMonitor.getMemoryInfo()
        
        // Verify memory values are logical
        XCTAssertGreaterThan(memoryInfo.total, 0, "Total memory should be positive")
        XCTAssertGreaterThanOrEqual(memoryInfo.used, 0, "Used memory should be non-negative")
        XCTAssertGreaterThanOrEqual(memoryInfo.free, 0, "Free memory should be non-negative")
        XCTAssertLessThanOrEqual(memoryInfo.used, memoryInfo.total, "Used memory should not exceed total")
        
        // Verify pressure is in valid range
        XCTAssertGreaterThanOrEqual(memoryInfo.pressure, 0.0, "Memory pressure should be non-negative")
        XCTAssertLessThanOrEqual(memoryInfo.pressure, 1.0, "Memory pressure should not exceed 100%")
    }
    
    func testGetMemoryInfoTotalCalculation() {
        let memoryInfo = systemMonitor.getMemoryInfo()
        
        // Used + free should be approximately equal to total (accounting for some system overhead)
        let sum = memoryInfo.used + memoryInfo.free
        let difference = abs(Double(sum) - Double(memoryInfo.total))
        let tolerance = Double(memoryInfo.total) * 0.1 // 10% tolerance
        
        XCTAssertLessThan(difference, tolerance, "Used + free should be close to total memory")
    }
    
    // MARK: - Disk Info Tests
    
    func testGetDiskInfo() {
        let diskInfo = systemMonitor.getDiskInfo()
        
        // Verify disk values are logical
        XCTAssertGreaterThan(diskInfo.total, 0, "Total disk space should be positive")
        XCTAssertGreaterThanOrEqual(diskInfo.used, 0, "Used disk space should be non-negative")
        XCTAssertGreaterThanOrEqual(diskInfo.free, 0, "Free disk space should be non-negative")
        XCTAssertLessThanOrEqual(diskInfo.used, diskInfo.total, "Used disk space should not exceed total")
    }
    
    func testGetDiskInfoConsistency() {
        let diskInfo1 = systemMonitor.getDiskInfo()
        let diskInfo2 = systemMonitor.getDiskInfo()
        
        // Disk total should remain consistent
        XCTAssertEqual(diskInfo1.total, diskInfo2.total, "Total disk space should be consistent")
    }
    
    // MARK: - Network Info Tests
    
    func testGetNetworkInfo() {
        let networkInfo = systemMonitor.getNetworkInfo()
        
        // Verify network stats are non-negative
        XCTAssertGreaterThanOrEqual(networkInfo.bytesIn, 0, "Bytes in should be non-negative")
        XCTAssertGreaterThanOrEqual(networkInfo.bytesOut, 0, "Bytes out should be non-negative")
        XCTAssertGreaterThanOrEqual(networkInfo.packetsIn, 0, "Packets in should be non-negative")
        XCTAssertGreaterThanOrEqual(networkInfo.packetsOut, 0, "Packets out should be non-negative")
    }
    
    // MARK: - Uptime Tests
    
    func testGetUptime() {
        let uptime = systemMonitor.getUptime()
        
        // Verify uptime is positive
        XCTAssertGreaterThan(uptime, 0, "Uptime should be positive")
        
        // Verify uptime is reasonable (less than a year in seconds)
        XCTAssertLessThan(uptime, 365 * 24 * 3600, "Uptime should be less than a year")
    }
    
    // MARK: - Process Info Tests
    
    func testGetProcessInfo() {
        let processInfo = systemMonitor.getProcessInfo()
        
        // Verify the dictionary contains expected keys
        XCTAssertNotNil(processInfo["processCount"], "Process info should contain processCount")
        XCTAssertNotNil(processInfo["threadCount"], "Process info should contain threadCount")
        
        // Verify values are reasonable
        if let processCount = processInfo["processCount"] as? Int {
            XCTAssertGreaterThan(processCount, 0, "Process count should be positive")
        }
    }
    
    // MARK: - Battery Info Tests
    
    func testGetBatteryInfo() {
        let battery = systemMonitor.getBatteryInfo()
        
        // Battery info may be nil on systems without a battery (e.g., desktops)
        // But if it exists, it should be valid
        if let level = battery.level {
            XCTAssertGreaterThanOrEqual(level, 0.0, "Battery level should be non-negative")
            XCTAssertLessThanOrEqual(level, 1.0, "Battery level should not exceed 100%")
        }
        
        // isCharging can be nil, true, or false - all are valid
    }
    
    // MARK: - Status Tests
    
    func testGetStatus() {
        let status = systemMonitor.getStatus()
        
        // Verify all components are present
        XCTAssertFalse(status.timestamp.isEmpty, "Timestamp should not be empty")
        XCTAssertGreaterThanOrEqual(status.cpu.usage, 0.0, "CPU usage should be valid")
        XCTAssertGreaterThan(status.memory.total, 0, "Memory total should be positive")
        XCTAssertGreaterThan(status.disk.total, 0, "Disk total should be positive")
        XCTAssertGreaterThanOrEqual(status.network.bytesIn, 0, "Network bytes in should be valid")
        XCTAssertGreaterThan(status.uptime, 0, "Uptime should be positive")
        XCTAssertGreaterThan(status.processCount, 0, "Process count should be positive")
    }
    
    func testGetStatusTimestampFormat() {
        let status = systemMonitor.getStatus()
        
        // Verify timestamp is in ISO8601 format
        let isoFormatter = ISO8601DateFormatter()
        let date = isoFormatter.date(from: status.timestamp)
        
        XCTAssertNotNil(date, "Timestamp should be in ISO8601 format")
    }
    
    func testMultipleStatusCalls() {
        // Call getStatus multiple times to ensure no crashes
        for _ in 0..<5 {
            let status = systemMonitor.getStatus()
            XCTAssertGreaterThan(status.uptime, 0)
        }
    }
    
    func testStatusComponentsAreValid() {
        let status = systemMonitor.getStatus()
        
        // Verify CPU info
        XCTAssertGreaterThan(status.cpu.coreCount, 0, "CPU core count should be positive")
        XCTAssertGreaterThanOrEqual(status.cpu.usage, 0.0, "CPU usage should be non-negative")
        XCTAssertLessThanOrEqual(status.cpu.usage, 1.0, "CPU usage should not exceed 100%")
        
        // Verify memory info
        XCTAssertGreaterThan(status.memory.total, 0, "Total memory should be positive")
        XCTAssertGreaterThanOrEqual(status.memory.pressure, 0.0, "Memory pressure should be non-negative")
        XCTAssertLessThanOrEqual(status.memory.pressure, 1.0, "Memory pressure should not exceed 100%")
        
        // Verify disk info
        XCTAssertGreaterThan(status.disk.total, 0, "Total disk space should be positive")
        XCTAssertLessThanOrEqual(status.disk.used, status.disk.total, "Used disk should not exceed total")
        
        // Verify thread count (may be 0 in simplified implementation)
        XCTAssertGreaterThanOrEqual(status.threadCount, 0, "Thread count should be non-negative")
    }
}

