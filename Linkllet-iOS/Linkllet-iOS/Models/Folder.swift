//
//  Folder.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/18.
//

import Foundation

struct Folder: Codable, Equatable {

    let id: Int64
    let name: String
    let type: FolderType
    let size: Int32

    enum CodingKeys: String, CodingKey {
        case id, name, type, size
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int64.self, forKey: .id) ?? -1
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        type = try container.decodeIfPresent(FolderType.self, forKey: .type) ?? .personalized
        size = try container.decodeIfPresent(Int32.self, forKey: .size) ?? 0
    }

    init(id: Int64, name: String, type: FolderType, size: Int32) {
        self.id = id
        self.name = name
        self.type = type
        self.size = size
    }
}

enum FolderType: String, Codable {

    case `default` = "DEFAULT"
    case personalized = "PERSONALIZED"
}
