//
//  UICollectionViewCell+.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/17.
//

import UIKit

extension UICollectionViewCell {

    static var className: String {
        return String(describing: Self.self)
    }
}
