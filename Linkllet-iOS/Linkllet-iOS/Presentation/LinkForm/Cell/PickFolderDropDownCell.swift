//
//  PickFolderDropDownCell.swift
//  Linkllet-iOS
//
//  Created by dochoi on 2023/07/19.
//

import Combine
import UIKit

final class PickFolderDropDownCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet {
            Task {
                await MainActor.run {
                    selectedImageView.isHidden = !isSelected
                }
            }
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var selectedImageView: UIImageView!
    var cancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectedImageView.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

}
