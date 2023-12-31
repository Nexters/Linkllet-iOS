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
    case editFolder(id: Int64, name: String)
    case deleteFolder(id: Int64)
    case getArticlesInFolder(folderID: String)
    case createArticleInFolder(articleName: String, articleURL: String, folderID: String)
    case deleteArticleInFolder(articleID: Int64, folderID: Int64)
    case searchArticles(content: String)
}

extension FolderEndpoint: Endpoint {
    var path: String {
        switch self {
        case .getFolders:
            return "folders"
        case .createFolder:
            return "folders"
        case .editFolder(let id, _):
            return "folders/\(id)"
        case .deleteFolder(let id):
            return "folders/\(id)"
        case .getArticlesInFolder(let id):
            return "folders/\(id)/articles"
        case .createArticleInFolder(_, _, let folderID):
            return "folders/\(folderID)/articles"
        case .deleteArticleInFolder(let articleID, let folderID):
            return "folders/\(folderID)/articles/\(articleID)"
        case .searchArticles(_):
            return "folders/search"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getFolders, .getArticlesInFolder, .searchArticles:
            return .get
        case .createFolder, .createArticleInFolder:
            return .post
        case .editFolder:
            return .put
        case .deleteFolder, .deleteArticleInFolder:
            return .delete
        }
    }

    var parameters: RequestParams {
        switch self {
        case .createFolder(let name):
            return .requestBody(["name": name])
        case .editFolder(_, let name):
            return .requestBody(["updateName": name])
        case .createArticleInFolder(let articleName, let articleURL, _):
            return .requestBody(["name": articleName, "url": articleURL])
        case .searchArticles(let content):
            return .requestQuery(["content": content])
        default:
            return .requestPlain
        }
    }

    var headers: HeaderType {
        return .auth
    }
}
