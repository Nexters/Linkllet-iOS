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

    @IBOutlet weak var textField: UITextField!
    @IBOutlet private weak var textFieldBackgroundView: UIView!

    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionStackView: UIStackView!

    @IBOutlet private weak var countLabel: UILabel!

    var cancellables = Set<AnyCancellable>()
    private var item: TextfieldLinkFormItem?

    override func awakeFromNib() {
        super.awakeFromNib()

        setView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    @IBAction func textFieldDidChange(_ sender: Any) {
        guard let maxCount = item?.maxCount else { return }
        countLabel.text = "\((textField.text ?? "").count)/\(maxCount)"
    }
}

extension LinkFormTextFieldCell {

    func updateUI(with item: TextfieldLinkFormItem) {
        self.item = item
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
        textField.delegate = self
    }
}

extension LinkFormTextFieldCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let maxCount = item?.maxCount else { return true }

        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        return newString.count <= maxCount
    }
}
