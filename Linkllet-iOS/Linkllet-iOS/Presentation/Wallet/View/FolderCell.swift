//
//  FolderCell.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/18.
//

import UIKit

final class FolderCell: UICollectionViewCell {
    
    // MARK: UI Component
    private let folderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 40
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        return view
    }()
    
    private let touchView: UIView = {
        let view = UIView()
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
        view.layer.borderColor = .init(red: 255, green: 255, blue: 255, alpha: 0.3)
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
    }
}

// MARK: - UI
extension FolderCell {
    
    private func setUI() {
        contentView.addSubview(folderView)
        contentView.addSubview(touchView)
        touchView.addSubview(titleLabel)
        touchView.addSubview(plusImageView)
        touchView.addSubview(countView)
        countView.addSubview(countLabel)
    }
    
    private func setConstraint() {
        folderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            folderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            folderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            folderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            folderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        touchView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            touchView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            touchView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            touchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            touchView.heightAnchor.constraint(equalToConstant: 46)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: touchView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: touchView.centerYAnchor)
        ])
        
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plusImageView.centerXAnchor.constraint(equalTo: touchView.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: touchView.centerYAnchor),
            plusImageView.widthAnchor.constraint(equalToConstant: 28),
            plusImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        countView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countView.trailingAnchor.constraint(equalTo: touchView.trailingAnchor),
            countView.centerYAnchor.constraint(equalTo: touchView.centerYAnchor),
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
        folderView.backgroundColor = .init("DAE3FB")
        folderView.layer.opacity = 0.8
        plusImageView.isHidden = false
        countView.isHidden = true
    }
    
    func setFolderCell(_ index: Int, _ data: Folder) {
        titleLabel.text = data.name
        switch (index - 1) % 3 {
        case 0:
            folderView.backgroundColor = .init("779CFF")
        case 1:
            folderView.backgroundColor = .init("4F7EFE")
        case 2:
            folderView.backgroundColor = .init("3467F0")
        default:
            break
        }
    }
}
