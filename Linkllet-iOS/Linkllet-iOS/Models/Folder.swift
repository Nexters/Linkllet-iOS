//
//  Folder.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/18.
//

import Foundation

struct Folder: Codable {

    let id: Int64
    let name: String
    let type: FolderType

    enum CodingKeys: String, CodingKey {
        case id, name, type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int64.self, forKey: .id) ?? -1
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        type = try container.decodeIfPresent(FolderType.self, forKey: .type) ?? .personalized
    }
}

enum FolderType: String, Codable {

    case `default` = "DEFAULT"
    case personalized = "personalized"
}
