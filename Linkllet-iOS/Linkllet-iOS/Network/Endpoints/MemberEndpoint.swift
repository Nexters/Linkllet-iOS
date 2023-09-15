//
//  MemberEndpoint.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/18.
//

import Foundation

enum MemberEndpoint {
    case register(userIdentifier: String)
    case createFeedback(feedback: String)
}

extension MemberEndpoint: Endpoint {
    var path: String {
        switch self {
        case .register(_):
            return "members"
        case .createFeedback(_):
            return "members/feedbacks"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .register(_), .createFeedback(_):
            return .post
        }
    }

    var parameters: RequestParams {
        switch self {
        case .register(let userIdentifier):
            return .requestBody(["deviceId": userIdentifier])
        case .createFeedback(let feedback):
            return .requestBody(["feedback": feedback])
        }
    }

    var headers: HeaderType {
        switch self {
        case .register, .createFeedback(_):
            return .auth
        }
    }
}
