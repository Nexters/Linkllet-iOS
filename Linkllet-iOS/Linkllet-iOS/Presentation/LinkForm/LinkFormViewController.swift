//
//  LinkFormViewController.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/17.
//

import Combine
import UIKit

final class LinkFormViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var actionButton: UIButton!

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: LinkFormViewModel

    init?(coder: NSCoder, viewModel: LinkFormViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("This viewController must be init with viewModel.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
        setPublisher()
    }

}

private extension LinkFormViewController {

    func setPublisher() {
        closeButton.tapPublisher
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)

        viewModel.state.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        actionButton.tapPublisher
            .sink { _ in

            }
            .store(in: &cancellables)
    }

    func setView() {
        actionButton.layer.cornerRadius = 12

        collectionView.register(UINib(nibName: LinkFormTextFieldCell.className, bundle: Bundle(for: LinkFormTextFieldCell.self)), forCellWithReuseIdentifier: LinkFormTextFieldCell.className)
        collectionView.register(UINib(nibName: PickFolderLinkFormCell.className, bundle: Bundle(for: PickFolderLinkFormCell.self)), forCellWithReuseIdentifier: PickFolderLinkFormCell.className)

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 40
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 40, right: 0)
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        updateActionButton(isEnabled: false)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCollectionView(_:)))
        tapGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGesture)
    }

    func updateActionButton(isEnabled: Bool) {
        actionButton.backgroundColor = isEnabled ? .black : .init("EDEDED")
        actionButton.setTitleColor(isEnabled ? .white : .init("878787"), for: .normal)
    
    }

    @objc
    func didTapCollectionView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension LinkFormViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.state.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item: LinkFormItem = viewModel.state.items.value[indexPath.item]
        switch item {
        case let item as CopiedLinkFormItem:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LinkFormTextFieldCell.className,
                for: indexPath
            ) as? LinkFormTextFieldCell else { return UICollectionViewCell() }
            cell.updateUI(with: item)
            return cell
        case let item as TitleLinkFormItem:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LinkFormTextFieldCell.className,
                for: indexPath
            ) as? LinkFormTextFieldCell else { return UICollectionViewCell() }
            cell.textField.keyboardType = .URL
            cell.updateUI(with: item)
            return cell
        case let item as PickFolderLinkFormItem:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PickFolderLinkFormCell.className,
                for: indexPath
            ) as? PickFolderLinkFormCell else { return UICollectionViewCell() }
            cell.updateUI(with: item, selectedFolder: viewModel.state.selectedFolder.value)
            cell.isExpandedPublisher
                .dropFirst(1)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isExapanded in
                    guard let self else { return }
                    var items = self.viewModel.state.items.value
                    guard let pickFolderItemIndex = items.firstIndex(where: { $0 is PickFolderLinkFormItem }),
                    var pickFolderItem = items[pickFolderItemIndex] as? PickFolderLinkFormItem else { return }
                    pickFolderItem.isExapanded = isExapanded
                    items[pickFolderItemIndex] = pickFolderItem
                    self.viewModel.state.items.send(items)
                }
                .store(in: &cell.cancellables)

            viewModel.state.selectedFolder
                .receive(on: DispatchQueue.main)
                .sink { [weak cell] folder in
                    cell?.selectedFolderTitleLabel.text = folder?.name
                }
                .store(in: &cell.cancellables)

            cell.didSelectItemPublisher
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] folder in
                    self?.viewModel.state.selectedFolder.send(folder)
                }
                .store(in: &cell.cancellables)

            return cell
        default:
            return UICollectionViewCell()
        }
    }

}

extension LinkFormViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = viewModel.state.items.value[indexPath.item]

        return CGSize(width: collectionView.bounds.width, height: item.height)
    }
}

extension LinkFormViewController {

    static func create(viewModel: LinkFormViewModel) -> LinkFormViewController? {
        let storyboard = UIStoryboard(name: "LinkForm", bundle: Bundle(for: LinkFormViewController.self))
        let viewContoller = storyboard.instantiateViewController(
            identifier: LinkFormViewController.className,
            creator: { coder -> LinkFormViewController? in
                return LinkFormViewController(coder: coder, viewModel: viewModel)})
        return viewContoller
    }
}

protocol LinkFormItem {
    var height : CGFloat { get }
}

protocol TextfieldLinkFormItem: LinkFormItem {

    var title: String { get }
    var placeholder: String? { get }
    var description: String? { get }
    var maxCount: Int? { get }
}

struct CopiedLinkFormItem: TextfieldLinkFormItem {

    let title: String = "복사한 링크"
    let placeholder: String? = "링크를 붙여주세요"
    let description: String? = nil
    let maxCount: Int? = nil
    let height : CGFloat = 82
}

struct TitleLinkFormItem: TextfieldLinkFormItem {

    let title: String = "링크 제목"
    let placeholder: String? = "제목을 입력해주세요"
    let description: String? = "※ 최대 10자까지 입력할 수 있어요."
    let maxCount: Int? = 10
    let height : CGFloat = 106
}


struct PickFolderLinkFormItem: LinkFormItem {

    var folders: [Folder]
    var height : CGFloat {
        return isExapanded ? 302 : 106
    }
    var isExapanded: Bool = false
}


final class LinkFormViewModel {

    struct State {
        let items = CurrentValueSubject<[LinkFormItem], Never>([])
        let selectedFolder = CurrentValueSubject<Folder?, Never>(nil)
    }

    let state = State()
    private let network: NetworkProvider = NetworkService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setData()
    }

    func setData() {
        network.request(FolderEndpoint.getFolders)
            .tryMap { (data, _) -> [Folder] in
                let decoder = JSONDecoder()
                let folders = try decoder.decode([Folder].self, from: data, keyPath: "folderList")
                return folders
            }
            .print()
//          replaceError가 아니라  .catch, completion으로 핸들링하는법 고민
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] folders in

                self?.state.selectedFolder.send(folders.first { $0.type == .default })
                self?.state.items.send([CopiedLinkFormItem(), TitleLinkFormItem(), PickFolderLinkFormItem(folders: folders)])
                
            }
            .store(in: &cancellables)
    }
}
