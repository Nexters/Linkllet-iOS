//
//  PickFolderDropDownHeader.swift
//  Linkllet-iOS
//
//  Created by dochoi on 2023/07/20.
//

import Combine
import UIKit

final class PickFolderDropDownHeader: UICollectionReusableView {

    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    var cancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .init("F4F4F4")
        separatorView.backgroundColor = .init("#EDEDED")
    }
}
