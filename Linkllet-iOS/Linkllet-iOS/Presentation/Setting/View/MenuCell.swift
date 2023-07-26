//
//  MenuCell.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/26.
//

import UIKit

final class MenuCell: UITableViewCell {
    
    // MARK: UI Component
    private let menuTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .PretendardB(size: 14)
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_info"), for: .normal)
        return button
    }()
    
    // MARK: Life Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
        setConstraint()
    }
}

// MARK: - UI
extension MenuCell {
    
    private func setUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(menuTitleLabel)
        contentView.addSubview(infoButton)
    }
    
    private func setConstraint() {
        menuTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            menuTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
        ])
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            infoButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}

// MARK: - Custom Methods
extension MenuCell {
    
    func setTitle(_ title: String) {
        menuTitleLabel.text = title
    }
}
