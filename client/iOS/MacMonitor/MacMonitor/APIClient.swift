//
//  APIClient.swift
//  MacMonitor
//
//  Created on 2026-02-06.
//

import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
}

class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
    }
    
    // MARK: - API Endpoints
    
    func fetchStatus(from device: Device) -> AnyPublisher<SystemStatus, APIError> {
        let urlString = "\(device.baseURL)/api/status"
        return fetch(urlString: urlString)
    }
    
    func fetchInfo(from device: Device) -> AnyPublisher<SystemInfo, APIError> {
        let urlString = "\(device.baseURL)/api/info"
        return fetch(urlString: urlString)
    }
    
    func checkHealth(from device: Device) -> AnyPublisher<HealthStatus, APIError> {
        let urlString = "\(device.baseURL)/health"
        return fetch(urlString: urlString)
    }
    
    // MARK: - Private Methods
    
    private func fetch<T: Decodable>(urlString: String) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<T, APIError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: APIError.serverError(0)).eraseToAnyPublisher()
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.serverError(httpResponse.statusCode)).eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: T.self, decoder: self.decoder)
                    .mapError { APIError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
