//
//  FolderEndpoint.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/17.
//

import Foundation

enum FolderEndpoint {
    case getFolders
    case createFolder(name: String)
    case deleteFolder(id: Int64)
    case getArticlesInFolder(folderID: String)
    case createArticleInFolder(articleName: String, articleURL: String, folderID: String)
    case deleteArticleInFolder(articleID: Int64, folderID: Int64)
}

extension FolderEndpoint: Endpoint {
    var path: String {
        switch self {
        case .getFolders:
            return "folders"
        case .createFolder:
            return "folders"
        case .deleteFolder(let id):
            return "folders/\(id)"
        case .getArticlesInFolder(let id):
            return "folders/\(id)/articles"
        case .createArticleInFolder(_, _, let folderID):
            return "folders/\(folderID)/articles"
        case .deleteArticleInFolder(let articleID, let folderID):
            return "folders/\(folderID)/articles/\(articleID)"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getFolders, .getArticlesInFolder:
            return .get
        case .createFolder, .createArticleInFolder:
            return .post
        case .deleteFolder, .deleteArticleInFolder:
            return .delete
        }
    }

    var parameters: RequestParams {
        switch self {
        case .createFolder(let name):
            return .requestBody(["name": name])
        case .createArticleInFolder(let articleName, let articleURL, _):
            return .requestBody(["name": articleName, "url": articleURL])
        default:
            return .requestPlain
        }
    }

    var headers: HeaderType {
        return .auth
    }
}
