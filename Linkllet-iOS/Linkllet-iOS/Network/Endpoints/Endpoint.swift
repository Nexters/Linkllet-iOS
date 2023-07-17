//
//  Endpoints.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/17.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: HeaderType { get }
    var parameters: RequestParams { get }
    var urlRequest: URLRequest? { get }
}

extension Endpoint {
    var baseURL: URL {
        return URL(string: "http://52.78.166.82:8080/api/v1/")!
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        request = self.makeHeaderForRequest(to: request)
        return try? self.makeParameterForRequest(to: request, with: url)
    }
    
    private func makeHeaderForRequest(to request: URLRequest) -> URLRequest {
        var request = request

        switch headers {
        case .basic:
            request.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)

        case .auth:
            
            // TODO: - auth value 수정
            request.setValue("", forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
            request.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        }

        return request
    }

    private func makeParameterForRequest(to request: URLRequest, with url: URL) throws -> URLRequest {
        var request = request

        switch parameters {
        case .requestQuery(let query):
            let queryParams = query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            var components = URLComponents(string: url.absoluteString)
            components?.queryItems = queryParams
            request.url = components?.url

        case .requestQueryBody(let query, let body):
            let queryParams = query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            var components = URLComponents(string: url.absoluteString)
            components?.queryItems = queryParams
            request.url = components?.url

            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        case .requestBody(let body):
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        case .requestPlain:
            break
        }

        return request
    }
}
