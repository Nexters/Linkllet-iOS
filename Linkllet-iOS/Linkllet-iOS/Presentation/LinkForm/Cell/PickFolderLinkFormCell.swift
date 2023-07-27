//
//  PickFolderLinkFormCell.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/18.
//

import Combine
import UIKit

final class PickFolderLinkFormCell: UICollectionViewCell {

    @IBOutlet weak var selectedFolderTitleLabel: UILabel!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dropDownBackgroundView: UIView!

    @IBOutlet private weak var descriptionLabel: UILabel!

    @IBOutlet private weak var collectionView: UICollectionView!

    var cancellables = Set<AnyCancellable>()

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    private(set) var isExpandedPublisher = CurrentValueSubject<Bool, Never>(false)
    private(set) var didSelectItemPublisher = CurrentValueSubject<Folder?, Never>(nil)

    private var linkFormItem: PickFolderLinkFormItem?

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

    func updateUI(with item: PickFolderLinkFormItem, selectedFolder: Folder?) {
        self.linkFormItem = item
        collectionViewHeightConstraint.constant = CGFloat((min(item.folders.count, 4) + 1) * 49)
        collectionView.layoutIfNeeded()
        titleLabel.text = "폴더 선택"
        descriptionLabel.text = "※ 폴더 미선택시 기본 폴더에 저장됩니다."
        collectionView.reloadData()
        collectionView.performBatchUpdates { [weak self] in
            guard let index = item.folders.firstIndex(where: { $0 == selectedFolder }) else { return }
            self?.collectionView.selectItem(at: .init(item: index, section: .zero), animated: false, scrollPosition: .centeredVertically)
            self?.didSelectItemPublisher.send(item.folders[index])
        }

    }
}

private extension PickFolderLinkFormCell {

    func setView() {
        dropDownBackgroundView.backgroundColor = .gray_01
        dropDownBackgroundView.layer.borderWidth = 1
        dropDownBackgroundView.layer.borderColor = UIColor.gray_02.cgColor
        dropDownBackgroundView.layer.cornerRadius = 12

        collectionView.isHidden = true

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .gray_01
        collectionView.layer.cornerRadius = 12
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor.gray_02.cgColor
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false


        collectionView.register(UINib(nibName: PickFolderDropDownCell.className, bundle: Bundle(for: PickFolderDropDownCell.self)), forCellWithReuseIdentifier: PickFolderDropDownCell.className)
        collectionView.register(UINib(nibName: PickFolderDropDownHeader.className, bundle: Bundle(for: PickFolderDropDownHeader.self)), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PickFolderDropDownHeader.className)
    }
}

extension PickFolderLinkFormCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return linkFormItem?.folders.count ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PickFolderDropDownCell.className,
            for: indexPath
        ) as? PickFolderDropDownCell else { return UICollectionViewCell() }
        guard let folder: Folder = linkFormItem?.folders[indexPath.item] else { return cell }
        cell.titleLabel.text = folder.name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PickFolderDropDownHeader.className, for: indexPath) as? PickFolderDropDownHeader else { return UICollectionReusableView() }
            headerView.publisher(for: UITapGestureRecognizer())
                .filter { $0.state == .recognized }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.isExpandedPublisher.send(false)
                }
                .store(in: &headerView.cancellables)

            dropDownBackgroundView.publisher(for: UITapGestureRecognizer())
                .filter { $0.state == .recognized }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.isExpandedPublisher.send(true)
                }
                .store(in: &headerView.cancellables)

            isExpandedPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isExpanded in
                    self?.collectionView.isHidden = !isExpanded
                }
                .store(in: &headerView.cancellables)

            didSelectItemPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak headerView] folder in
                    headerView?.titleLabel.text = folder?.name
                }
                .store(in: &headerView.cancellables)
            return headerView
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let folder: Folder = linkFormItem?.folders[indexPath.item] else { return }
        didSelectItemPublisher.send(folder)
    }

}

extension PickFolderLinkFormCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 49)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 49)
    }
}
