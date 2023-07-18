//
//  MemberEndpoint.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/18.
//

import Foundation

enum MemberEndpoint {
    case register
}

extension MemberEndpoint: Endpoint {
    var path: String {
        switch self {
        case .register:
            return "members"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .register:
            return .post
        }
    }

    var parameters: RequestParams {
        switch self {
        case .register:
            return .requestBody(["deviceId": MemberInfoManager.deviceId])
        }
    }

    var headers: HeaderType {
        switch self {
        case .register:
            return .auth
        }
    }
}
