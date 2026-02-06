import Foundation
#if os(macOS)
import AppKit
#endif

@main
struct MacMonitorAgent {
    static func main() async throws {
        print("🚀 Starting Mac Monitor Agent (Swift)...")
        
        let port = 8080
        
        // Create shared system monitor
        let monitor = SystemMonitor()
        
        // Start Bonjour service
        let bonjour = BonjourPublisher(port: port)
        bonjour.start()
        
        // Create and start API server
        let apiServer = APIServer(port: port)
        let app = apiServer.buildApplication()
        
        print("✅ HTTP API Server starting on http://0.0.0.0:\(port)")
        print("   Endpoints:")
        print("   - GET /health")
        print("   - GET /api/info")
        print("   - GET /api/status")
        
        #if os(macOS)
        // Start menu bar app (macOS only)
        let menuBarApp = MenuBarApp(monitor: monitor)
        
        // Run app in main thread for menu bar
        DispatchQueue.main.async {
            NSApplication.shared.setActivationPolicy(.accessory)
            menuBarApp.start()
        }
        
        print("✅ Menu bar app started")
        #else
        print("ℹ️  Menu bar app is only available on macOS")
        #endif
        
        // Start the server
        try await app.runService()
    }
}
