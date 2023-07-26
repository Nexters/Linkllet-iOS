//
//  LinkCell.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/20.
//

import UIKit
import Combine

final class LinkCell: UICollectionViewCell {
    
    // MARK: Properties
    private var cancellables = Set<AnyCancellable>()
    var deleteLinkClosure: (() -> ())?
    
    // MARK: UI Component
    private let backView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.init("EDEDED").cgColor
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .PretendardB(size: 14)
        label.text = "자소서 참고"
        label.textColor = .black
        return label
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = .PretendardM(size: 12)
        label.text = "https://brunch.co.kr/@plus.."
        label.textColor = .init("878787")
        return label
    }()
    
    private let saveDateLabel: UILabel = {
        let label = UILabel()
        label.font = .PretendardM(size: 12)
        label.text = "저장일 ∣ 2023.7.8"
        label.textColor = .black
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_more"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setConstraint()
        setPublisher()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
        setConstraint()
        setPublisher()
    }
}

// MARK: - UI
extension LinkCell {
    
    private func setUI() {
        contentView.addSubview(backView)
        [titleLabel, urlLabel, saveDateLabel, moreButton].forEach { backView.addSubview($0) }
    }
    
    private func setConstraint() {
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            urlLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            urlLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        saveDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveDateLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 12),
            saveDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        ])
        
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moreButton.topAnchor.constraint(equalTo: backView.topAnchor, constant: 20),
            moreButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -18),
            moreButton.heightAnchor.constraint(equalToConstant: 28),
            moreButton.widthAnchor.constraint(equalToConstant: 28),
        ])
    }
}

// MARK: - Custom Methods
extension LinkCell {
    
    func setLinkCell(_ data: Article) {
        titleLabel.text = data.name
        urlLabel.text = data.url?.absoluteString
        saveDateLabel.text = "저장일 ∣ \(data.createAt.split(separator: " ")[0])"
    }
    
    private func setPublisher() {
        moreButton.tapPublisher
            .sink { [weak self] _ in
                let delete = UIAction(title: "링크 삭제하기", handler: { _ in
                    self?.deleteLinkClosure?()
                })
                self?.moreButton.menu = UIMenu(children: [delete])
            }
            .store(in: &cancellables)
    }
}
