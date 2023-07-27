//
//  FolderCell.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/18.
//

import UIKit

final class FolderCell: UICollectionViewCell {
    
    // MARK: UI Component
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 40
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        return view
    }()
    
    private let plusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ico_plus")
        imageView.isHidden = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .PretendardB(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let countView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return view
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .PretendardB(size: 12)
        label.textColor = .white
        return label
    }()
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
        setConstraint()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
}

// MARK: - UI
extension FolderCell {
    
    private func setUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(plusImageView)
        cardView.addSubview(countView)
        countView.addSubview(countLabel)
    }
    
    private func setConstraint() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 26)
        ])
        
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plusImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            plusImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 19),
            plusImageView.widthAnchor.constraint(equalToConstant: 28),
            plusImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        countView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -32),
            countView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            countView.heightAnchor.constraint(equalToConstant: 22),
            countView.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: countView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: countView.centerYAnchor),
        ])
    }
}

// MARK: - UI
extension FolderCell {
    
    func setPlusCell() {
        cardView.backgroundColor = .blue_01
        cardView.layer.opacity = 0.8
        plusImageView.isHidden = false
        countView.isHidden = true
    }
    
    func setFolderCell(_ index: Int, _ data: Folder) {
        titleLabel.text = data.name
        countLabel.text = String(data.size)
        switch (index - 1) % 3 {
        case 0:
            cardView.backgroundColor = .blue_02
        case 1:
            cardView.backgroundColor = .blue_03
        case 2:
            cardView.backgroundColor = .blue_04
        default:
            break
        }
    }
    
    private func resetCell() {
        plusImageView.isHidden = true
        titleLabel.text = nil
        countLabel.text = nil
        countView.isHidden = false
        cardView.layer.opacity = 1
    }
}
