//
//  LinkFormViewController.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/17.
//

import Combine
import UIKit

final class LinkFormViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: LinkFormViewModel
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var closeButton: UIButton!

    init?(coder: NSCoder, viewModel: LinkFormViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("This viewController must be init with viewModel.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: LinkFormTextFieldCell.className, bundle: Bundle(for: LinkFormTextFieldCell.self)), forCellWithReuseIdentifier: LinkFormTextFieldCell.className)
        collectionView.register(UINib(nibName: PickFolderLinkFormCell.className, bundle: Bundle(for: PickFolderLinkFormCell.self)), forCellWithReuseIdentifier: PickFolderLinkFormCell.className)
        setPublisher()
        setView()
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
    }

    func setView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 40
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 40, right: 0)
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
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
            cell.updateUI(with: item)
            return cell
        case let item as PickFolderLinkFormItem:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PickFolderLinkFormCell.className,
                for: indexPath
            ) as? PickFolderLinkFormCell else { return UICollectionViewCell() }
            cell.updateUI(with: item)
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
    var folders: [Folder] = []
    let height : CGFloat = 106
}


final class LinkFormViewModel {

    struct State {
        let items = CurrentValueSubject<[LinkFormItem], Never>([])
    }

    let state = State()

    init() {
        setData()
    }

    func setData() {
        state.items.send([CopiedLinkFormItem(), TitleLinkFormItem(), PickFolderLinkFormItem()])
    }
}

struct Folder: Decodable {
    var nameString: String
}

