//
//  NetworkConstants.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/17.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse(message: String)
    case invalidRequest(message: String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return localizedDescription
        case .invalidResponse(let message):
            return message
        case .invalidRequest(let message):
            return message
        case .decodingFailed:
            return localizedDescription
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum HeaderType {
    case basic
    case auth
}

enum HTTPHeaderField: String {
    case contentType = "Content-Type"
    case deviceID = "Device-Id"
}

enum ContentType: String {
    case json = "application/json"
}

enum RequestParams {
    case requestQuery(_ query: [String : Any])
    case requestQueryBody(_ query: [String : Any], _ body: [String : Any])
    case requestBody(_ body: [String : Any])
    case requestPlain
}
