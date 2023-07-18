//
//  Article.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/18.
//

import Foundation

struct Article: Codable {

    let id: Int64
    let name: String
    let url: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int64.self, forKey: .id) ?? -1
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        url = try container.decodeIfPresent(URL.self, forKey: .url)
    }
}
