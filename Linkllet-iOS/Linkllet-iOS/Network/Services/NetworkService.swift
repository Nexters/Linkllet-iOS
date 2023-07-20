//
//  Network.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/17.
//

import Foundation
import Combine

protocol NetworkProvider {
    func request(_ endpoint: Endpoint) -> AnyPublisher<(Data, URLResponse), NetworkError>
}

final class NetworkService: NetworkProvider {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request(_ endpoint: Endpoint) -> AnyPublisher<(Data, URLResponse), NetworkError> {
        guard let urlRequest = endpoint.urlRequest else {
            return Fail<(Data, URLResponse), NetworkError>(error: .invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      [200, 400].contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                return (data, response)
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.decodingFailed
                }
            }
            .eraseToAnyPublisher()
    }
}

public extension JSONDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data, keyPath: String) throws -> T {
        let toplevel = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        if let nestedJson = (toplevel as AnyObject).value(forKeyPath: keyPath) {
            let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedJson, options: .fragmentsAllowed)
            return try decode(type, from: nestedJsonData)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Nested json not found for key path \"\(keyPath)\""))
        }
    }
}
