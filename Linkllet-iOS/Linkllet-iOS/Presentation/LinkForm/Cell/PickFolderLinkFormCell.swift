//
//  PickFolderLinkFormCell.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/18.
//

import Combine
import UIKit

final class PickFolderLinkFormCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dropDownBackgroundView: UIView!

    @IBOutlet private weak var descriptionLabel: UILabel!

    var cancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        setView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
}

extension PickFolderLinkFormCell {

    func updateUI(with item: PickFolderLinkFormItem) {
        titleLabel.text = "폴더 선택"
        descriptionLabel.text = "※ 폴더 미선택시 기본 폴더에 저장됩니다."
    }
}

private extension PickFolderLinkFormCell {

    func setView() {
        dropDownBackgroundView.backgroundColor = .init("F4F4F4")
        dropDownBackgroundView.layer.borderWidth = 1
        dropDownBackgroundView.layer.borderColor = UIColor("E0E0E0").cgColor
        dropDownBackgroundView.layer.cornerRadius = 12
    }
}
