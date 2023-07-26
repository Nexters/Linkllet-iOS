//
//  UITableViewCell+.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/26.
//

import UIKit

extension UITableViewCell {

    static var className: String {
        return String(describing: Self.self)
    }
}
