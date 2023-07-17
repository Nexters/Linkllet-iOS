//
//  FolderEndpoint.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/17.
//

import Foundation

enum FolderEndpoint {
    case getFolders
}

extension FolderEndpoint: Endpoint {
    var path: String {
        switch self {
        case .getFolders:
            return "search/image"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getFolders:
            return .get
        }
    }

    var parameters: RequestParams {
        switch self {
        case .getFolders:
            return .requestPlain
        }
    }

    var headers: HeaderType {
        switch self {
        case .getFolders:
            return .auth
        }
    }
}
