import Foundation

#if os(macOS)
import NetService
#endif

/// Publishes Mac Monitor service via Bonjour/mDNS
class BonjourPublisher: NSObject {
    #if os(macOS)
    private var netService: NetService?
    #endif
    private let port: Int
    private let serviceName: String
    private let serviceType: String
    
    init(port: Int, serviceName: String = "", serviceType: String = "_macmonitor._tcp.") {
        self.port = port
        self.serviceName = serviceName.isEmpty ? ProcessInfo.processInfo.hostName : serviceName
        self.serviceType = serviceType
        super.init()
    }
    
    func start() {
        #if os(macOS)
        netService = NetService(domain: "local.", type: serviceType, name: serviceName, port: Int32(port))
        netService?.delegate = self
        netService?.publish()
        
        print("📡 Publishing Bonjour service: \(serviceName) on port \(port)")
        #else
        print("ℹ️  Bonjour service is only available on macOS")
        #endif
    }
    
    func stop() {
        #if os(macOS)
        netService?.stop()
        netService = nil
        print("⏹️ Bonjour service stopped")
        #endif
    }
}

#if os(macOS)
extension BonjourPublisher: NetServiceDelegate {
    func netServiceDidPublish(_ sender: NetService) {
        print("✅ Bonjour service published successfully: \(sender.name)")
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("❌ Failed to publish Bonjour service: \(errorDict)")
    }
    
    func netServiceDidStop(_ sender: NetService) {
        print("🛑 Bonjour service stopped")
    }
}
#endif
