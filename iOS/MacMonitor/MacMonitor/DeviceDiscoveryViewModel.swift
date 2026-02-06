//
//  DeviceDiscoveryViewModel.swift
//  MacMonitor
//
//  Created on 2026-02-06.
//

import Foundation
import Network
import Combine

class DeviceDiscoveryViewModel: ObservableObject {
    @Published var discoveredDevices: [Device] = []
    
    private var browser: NWBrowser?
    private let queue = DispatchQueue(label: "com.macmonitor.discovery")
    
    func startDiscovery() {
        // Create a browser for _macmonitor._tcp service
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        browser = NWBrowser(for: .bonjour(type: "_macmonitor._tcp", domain: nil), using: parameters)
        
        browser?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("Browser is ready")
            case .failed(let error):
                print("Browser failed with error: \(error)")
                self?.stopDiscovery()
            case .cancelled:
                print("Browser cancelled")
            default:
                break
            }
        }
        
        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            self?.handleBrowseResults(results)
        }
        
        browser?.start(queue: queue)
        
        // Also try to discover on localhost for testing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.discoverLocalDevices()
        }
    }
    
    func stopDiscovery() {
        browser?.cancel()
        browser = nil
    }
    
    private func handleBrowseResults(_ results: Set<NWBrowser.Result>) {
        var devices: [Device] = []
        
        for result in results {
            switch result.endpoint {
            case .service(let name, let type, let domain, _):
                // Extract device information from service
                let deviceName = name
                
                // For now, use default port and localhost
                // In a real implementation, you would resolve the service to get actual host/port
                let device = Device(
                    id: "\(name).\(type).\(domain)",
                    name: deviceName,
                    host: "localhost",
                    port: 8080
                )
                devices.append(device)
                
            default:
                break
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.discoveredDevices = devices
        }
    }
    
    private func discoverLocalDevices() {
        // Try common local hosts
        let localHosts = [
            ("localhost", 8080),
            ("127.0.0.1", 8080)
        ]
        
        for (host, port) in localHosts {
            checkDevice(host: host, port: port)
        }
    }
    
    private func checkDevice(host: String, port: Int) {
        let url = URL(string: "http://\(host):\(port)/api/info")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let info = try? JSONDecoder().decode(SystemInfo.self, from: data) else {
                return
            }
            
            let device = Device(
                id: "\(host):\(port)",
                name: info.hostname,
                host: host,
                port: port
            )
            
            DispatchQueue.main.async {
                // Add device if not already present
                if !self!.discoveredDevices.contains(where: { $0.id == device.id }) {
                    self?.discoveredDevices.append(device)
                }
            }
        }.resume()
    }
}
