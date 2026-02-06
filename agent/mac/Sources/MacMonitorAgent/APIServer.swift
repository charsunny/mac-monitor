import Foundation
import Hummingbird

/// HTTP API server for Mac Monitor
struct APIServer {
    let monitor: SystemMonitor
    let port: Int
    
    init(port: Int = 8080) {
        self.monitor = SystemMonitor()
        self.port = port
    }
    
    func buildApplication() -> some ApplicationProtocol {
        let router = Router()
        
        // Health check endpoint
        router.get("/health") { _, _ in
            return HealthResponse(status: "ok")
        }
        
        // System info endpoint
        router.get("/api/info") { _, _ in
            let uname = ProcessInfo.processInfo
            return SystemInfoResponse(
                hostname: uname.hostName,
                osVersion: "\(uname.operatingSystemVersionString)",
                model: self.getModelIdentifier(),
                architecture: self.getArchitecture()
            )
        }
        
        // System status endpoint
        router.get("/api/status") { _, _ in
            return self.monitor.getStatus()
        }
        
        let app = Application(
            router: router,
            configuration: .init(
                address: .hostname("0.0.0.0", port: self.port),
                serverName: "MacMonitorAgent"
            )
        )
        
        return app
    }
    
    private func getModelIdentifier() -> String {
        #if os(macOS)
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
        #else
        return "Unknown"
        #endif
    }
    
    private func getArchitecture() -> String {
        #if arch(x86_64)
        return "x86_64"
        #elseif arch(arm64)
        return "arm64"
        #else
        return "unknown"
        #endif
    }
}
