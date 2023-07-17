//
//  LinkFormTextFieldCell.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/17.
//

import Combine
import UIKit

final class LinkFormTextFieldCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var textFieldBackgroundView: UIView!

    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionStackView: UIStackView!

    @IBOutlet private weak var countLabel: UILabel!

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

extension LinkFormTextFieldCell {

    func updateUI(with item: TextfieldLinkFormItem) {
        titleLabel.text = item.title
        textField.placeholder = item.placeholder
        countLabel.isHidden = item.maxCount == nil
        descriptionLabel.text = item.description
        descriptionStackView.isHidden = item.description == nil
    }
}

private extension LinkFormTextFieldCell {

    func setView() {
        textFieldBackgroundView.backgroundColor = .init("F4F4F4")
        textFieldBackgroundView.layer.borderWidth = 0
        textFieldBackgroundView.layer.cornerRadius = 12
    }
}
