import Foundation

#if os(macOS)
import IOKit.ps
import Darwin
#elseif os(Linux)
import Glibc
#endif

/// System monitoring class that collects system metrics
class SystemMonitor {
    private var lastNetworkStats: NetworkStats?
    private var lastNetworkTime: Date?
    
    struct NetworkStats {
        let bytesReceived: UInt64
        let bytesSent: UInt64
        let packetsReceived: UInt64
        let packetsSent: UInt64
    }
    
    // MARK: - CPU Monitoring
    
    func getCPUInfo() -> CPUInfo {
        let usage = getCPUUsage()
        let coreCount = ProcessInfo.processInfo.activeProcessorCount
        
        return CPUInfo(
            usage: usage,
            coreCount: coreCount,
            frequency: nil,
            temperature: nil
        )
    }
    
    private func getCPUUsage() -> Double {
        #if os(macOS)
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0
        var inUse: natural_t = 0
        var total: natural_t = 0
        
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &numCPUInfo
        )
        
        guard result == KERN_SUCCESS, let cpuInfo = cpuInfo else {
            return 0.0
        }
        
        for i in 0..<Int(numCPUs) {
            let cpuLoadInfo = cpuInfo.advanced(by: Int(i) * Int(CPU_STATE_MAX))
                .withMemoryRebound(to: integer_t.self, capacity: Int(CPU_STATE_MAX)) { $0 }
            
            inUse += natural_t(cpuLoadInfo[Int(CPU_STATE_USER)])
            inUse += natural_t(cpuLoadInfo[Int(CPU_STATE_SYSTEM)])
            inUse += natural_t(cpuLoadInfo[Int(CPU_STATE_NICE)])
            total += natural_t(cpuLoadInfo[Int(CPU_STATE_USER)])
            total += natural_t(cpuLoadInfo[Int(CPU_STATE_SYSTEM)])
            total += natural_t(cpuLoadInfo[Int(CPU_STATE_NICE)])
            total += natural_t(cpuLoadInfo[Int(CPU_STATE_IDLE)])
        }
        
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(numCPUInfo))
        
        return total > 0 ? Double(inUse) / Double(total) : 0.0
        #else
        // Stub for non-macOS platforms
        return 0.0
        #endif
    }
    
    // MARK: - Memory Monitoring
    
    func getMemoryInfo() -> MemoryInfo {
        #if os(macOS)
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        let pageSize = UInt64(vm_kernel_page_size)
        
        if result == KERN_SUCCESS {
            let free = UInt64(stats.free_count) * pageSize
            let active = UInt64(stats.active_count) * pageSize
            let inactive = UInt64(stats.inactive_count) * pageSize
            let wired = UInt64(stats.wire_count) * pageSize
            let compressed = UInt64(stats.compressor_page_count) * pageSize
            
            let used = active + wired + compressed
            let total = ProcessInfo.processInfo.physicalMemory
            let available = total - used
            
            return MemoryInfo(
                total: total,
                used: used,
                free: available,
                pressure: Double(used) / Double(total)
            )
        }
        #endif
        
        return MemoryInfo(
            total: 0,
            used: 0,
            free: 0,
            pressure: 0.0
        )
    }
    
    // MARK: - Disk Monitoring
    
    func getDiskInfo() -> DiskInfo {
        do {
            let fileURL = URL(fileURLWithPath: "/")
            let values = try fileURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey
            ])
            
            let total = UInt64(values.volumeTotalCapacity ?? 0)
            let available = UInt64(values.volumeAvailableCapacity ?? 0)
            let used = total - available
            
            return DiskInfo(
                total: total,
                used: used,
                free: available
            )
        } catch {
            return DiskInfo(
                total: 0,
                used: 0,
                free: 0
            )
        }
    }
    
    // MARK: - Network Monitoring
    
    func getNetworkInfo() -> NetworkInfo {
        let currentStats = getNetworkStats()
        let currentTime = Date()
        
        defer {
            lastNetworkStats = currentStats
            lastNetworkTime = currentTime
        }
        
        guard let lastStats = lastNetworkStats,
              let lastTime = lastNetworkTime else {
            return NetworkInfo(
                bytesIn: 0,
                bytesOut: 0,
                packetsIn: currentStats.packetsReceived,
                packetsOut: currentStats.packetsSent
            )
        }
        
        let timeDelta = currentTime.timeIntervalSince(lastTime)
        guard timeDelta > 0 else {
            return NetworkInfo(
                bytesIn: 0,
                bytesOut: 0,
                packetsIn: currentStats.packetsReceived,
                packetsOut: currentStats.packetsSent
            )
        }
        
        let bytesInRate = Int(Double(currentStats.bytesReceived - lastStats.bytesReceived) / timeDelta)
        let bytesOutRate = Int(Double(currentStats.bytesSent - lastStats.bytesSent) / timeDelta)
        
        return NetworkInfo(
            bytesIn: bytesInRate,
            bytesOut: bytesOutRate,
            packetsIn: currentStats.packetsReceived,
            packetsOut: currentStats.packetsSent
        )
    }
    
    private func getNetworkStats() -> NetworkStats {
        #if os(macOS)
        var ifaddrs: UnsafeMutablePointer<ifaddrs>?
        var bytesReceived: UInt64 = 0
        var bytesSent: UInt64 = 0
        var packetsReceived: UInt64 = 0
        var packetsSent: UInt64 = 0
        
        guard getifaddrs(&ifaddrs) == 0, let firstAddr = ifaddrs else {
            return NetworkStats(bytesReceived: 0, bytesSent: 0, packetsReceived: 0, packetsSent: 0)
        }
        
        var addr = firstAddr
        while true {
            let interface = addr.pointee
            
            if interface.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                let name = String(cString: interface.ifa_name)
                
                // Skip loopback
                if !name.hasPrefix("lo") {
                    if let data = interface.ifa_data?.assumingMemoryBound(to: if_data.self).pointee {
                        bytesReceived += UInt64(data.ifi_ibytes)
                        bytesSent += UInt64(data.ifi_obytes)
                        packetsReceived += UInt64(data.ifi_ipackets)
                        packetsSent += UInt64(data.ifi_opackets)
                    }
                }
            }
            
            guard let next = interface.ifa_next else { break }
            addr = next
        }
        
        freeifaddrs(firstAddr)
        
        return NetworkStats(
            bytesReceived: bytesReceived,
            bytesSent: bytesSent,
            packetsReceived: packetsReceived,
            packetsSent: packetsSent
        )
        #else
        return NetworkStats(bytesReceived: 0, bytesSent: 0, packetsReceived: 0, packetsSent: 0)
        #endif
    }
    
    // MARK: - System Info
    
    func getUptime() -> TimeInterval {
        #if os(macOS)
        var boottime = timeval()
        var size = MemoryLayout<timeval>.stride
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        
        sysctl(&mib, 2, &boottime, &size, nil, 0)
        
        let now = Date()
        let bootDate = Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec))
        return now.timeIntervalSince(bootDate)
        #else
        return 0
        #endif
    }
    
    func getProcessInfo() -> [String: Any] {
        let processCount = getProcessCount()
        let threadCount = getThreadCount()
        
        return [
            "processCount": processCount,
            "threadCount": threadCount
        ]
    }
    
    private func getProcessCount() -> Int {
        #if os(macOS)
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL]
        var size: size_t = 0
        
        sysctl(&mib, 3, nil, &size, nil, 0)
        
        let count = size / MemoryLayout<kinfo_proc>.stride
        return count
        #else
        return 0
        #endif
    }
    
    private func getThreadCount() -> Int {
        // Simplified thread count - just return 0 as it requires more complex implementation
        return 0
    }
    
    func getBatteryInfo() -> (level: Double?, isCharging: Bool?) {
        #if os(macOS)
        let powerSourceInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
        let powerSources = IOPSCopyPowerSourcesList(powerSourceInfo)?.takeRetainedValue() as? [CFTypeRef]
        
        guard let sources = powerSources, !sources.isEmpty else {
            return (nil, nil)
        }
        
        for source in sources {
            if let info = IOPSGetPowerSourceDescription(powerSourceInfo, source)?.takeUnretainedValue() as? [String: Any] {
                if let capacity = info[kIOPSCurrentCapacityKey] as? Int,
                   let maxCapacity = info[kIOPSMaxCapacityKey] as? Int,
                   let isCharging = info[kIOPSIsChargingKey] as? Bool {
                    let level = Double(capacity) / Double(maxCapacity)
                    return (level, isCharging)
                }
            }
        }
        #endif
        
        return (nil, nil)
    }
    
    // MARK: - Combined Status
    
    func getStatus() -> SystemStatusResponse {
        let cpu = getCPUInfo()
        let memory = getMemoryInfo()
        let disk = getDiskInfo()
        let network = getNetworkInfo()
        let processCount = getProcessCount()
        let threadCount = getThreadCount()
        let battery = getBatteryInfo()
        
        return SystemStatusResponse(
            timestamp: ISO8601DateFormatter().string(from: Date()),
            cpu: cpu,
            memory: memory,
            disk: disk,
            network: network,
            temperature: nil,
            uptime: getUptime(),
            processCount: processCount,
            threadCount: threadCount,
            batteryLevel: battery.level,
            isCharging: battery.isCharging
        )
    }
}
