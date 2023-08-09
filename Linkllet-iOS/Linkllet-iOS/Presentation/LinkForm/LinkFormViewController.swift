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
                let vc = PopupViewController(message: "작성한 내용이 삭제됩니다.\n작성을 취소할건가요?", confirmAction: {
                    self?.dismiss(animated: true)
                })
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self?.present(vc, animated: true, completion: nil)
            }
            .store(in: &cancellables)

        viewModel.state.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        actionButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel.action.completionAction.send(())
            }
            .store(in: &cancellables)

        viewModel.state.isActionButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.updateActionButton(isEnabled: isEnabled)
            }
            .store(in: &cancellables)

        viewModel.action.close
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let presentingVC = self?.presentingViewController as? UINavigationController else { return }
                let viewControllerStack = presentingVC.viewControllers
                
                self?.dismiss(animated: true) {
                    for viewController in viewControllerStack {
                        if let rootVC = viewController as? WalletViewController {
                            presentingVC.popToViewController(rootVC, animated: true)
                            
                            if let selectedFolder = self?.viewModel.state.selectedFolder.value {
                                let nextVC = LinkListViewController(viewModel: LinkListViewModel(networkService: NetworkService(), folder: selectedFolder))
                                presentingVC.pushViewController(nextVC, animated: true)
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.action.showToast
            .receive(on: DispatchQueue.main)
            .sink { reason in
                UIViewController.showToast(reason)
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
        actionButton.backgroundColor = isEnabled ? .black : .gray_02
        actionButton.setTitleColor(isEnabled ? .white : .gray_04, for: .normal)
    
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

            cell.textField.keyboardType = .URL
            cell.textField.text = viewModel.pastedUrl?.absoluteString
            cell.textFieldDidChangePublisher
                .sink { [weak self] urlString in
                    self?.viewModel.state.articleURLString.send(urlString)
                }
                .store(in: &cell.cancellables)

            viewModel.state.isArticleURLStringrHighlighted
                .receive(on: DispatchQueue.main)
                .sink { [weak cell] isHighlighted in
                    cell?.updateHighlighted(isHighlighted: isHighlighted)
                }
                .store(in: &cell.cancellables)

            cell.textFieldDidEndEditingPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let nextIndex = self?.viewModel.state.items.value.firstIndex(where: { $0 is TitleLinkFormItem }),
                    let titleLinkFormItemCell = self?.collectionView.cellForItem(at: .init(row: nextIndex, section: 0)) as? LinkFormTextFieldCell else { return }
                    titleLinkFormItemCell.textField.becomeFirstResponder()
                }
                .store(in: &cell.cancellables)

            return cell
        case let item as TitleLinkFormItem:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LinkFormTextFieldCell.className,
                for: indexPath
            ) as? LinkFormTextFieldCell else { return UICollectionViewCell() }
            cell.updateUI(with: item)

            cell.textFieldDidChangePublisher
                .sink { [weak self] nameString in
                    self?.viewModel.state.articleName.send(nameString)
                }
                .store(in: &cell.cancellables)

            viewModel.state.isArticleNameFormHighlighted
                .receive(on: DispatchQueue.main)
                .sink { [weak cell] isHighlighted in
                    cell?.updateHighlighted(isHighlighted: isHighlighted)
                }
                .store(in: &cell.cancellables)

            cell.textFieldDidEndEditingPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let nextIndex = self?.viewModel.state.items.value.firstIndex(where: { $0 is PickFolderLinkFormItem }),
                    let pickFolderLinkFormCell = self?.collectionView.cellForItem(at: .init(row: nextIndex, section: 0)) as? PickFolderLinkFormCell else { return }
                    pickFolderLinkFormCell.isExpandedPublisher.send(true)
                }
                .store(in: &cell.cancellables)

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
            
            cell.addFolderPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    let vc = FolderFormViewController(viewModel: FolderFormViewModel(networkService: NetworkService(), formType: .create))
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
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
        let articleName = CurrentValueSubject<String, Never>("")
        let articleURLString = CurrentValueSubject<String, Never>("")
        let isArticleNameFormHighlighted = CurrentValueSubject<Bool, Never>(false)
        let isArticleURLStringrHighlighted = CurrentValueSubject<Bool, Never>(false)
        let isActionButtonEnabled = CurrentValueSubject<Bool, Never>(false)
    }

    struct Action {
        let completionAction = PassthroughSubject<Void, Never>()
        let close = PassthroughSubject<Void, Never>()
        let showToast = PassthroughSubject<String, Never>()
    }

    let state = State()
    let action = Action()
    let initialFolder: Folder?
    let pastedUrl: URL?

    private let network: NetworkProvider = NetworkService()
    private var cancellables = Set<AnyCancellable>()

    init(initialFolder: Folder? = nil, pastedUrl: URL? = nil) {
        self.initialFolder = initialFolder
        self.pastedUrl = pastedUrl
        setPublisher()
        getFolders()
    }

    func setPublisher() {
        action.completionAction
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self else { return }
                self.state.isArticleURLStringrHighlighted.send(self.state.articleURLString.value.isEmpty)
                self.state.isArticleNameFormHighlighted.send(self.state.articleName.value.isEmpty)
            })
            .filter { [weak self] _ in
                guard let self else { return false }
                return self.isValid(folder: self.state.selectedFolder.value, articleName: self.state.articleName.value, articleURLString: self.state.articleURLString.value)
            }
            .compactMap { [weak self] _ -> AnyPublisher<Bool ,Never> in
                guard let self,
                      let selectedFolder = self.state.selectedFolder.value else { return Just(false).eraseToAnyPublisher() }
                return self.network.request(FolderEndpoint.createArticleInFolder(articleName: self.state.articleName.value, articleURL: self.state.articleURLString.value, folderID: "\(selectedFolder.id)"))
                    .tryMap { (data, response) -> Bool in
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                            let decoder = JSONDecoder()
                            let message = try? decoder.decode(String.self, from: data, keyPath: "message")
                            throw NetworkError.invalidResponse(message: message ?? "")
                        }
                        return true
                    }
                    .catch { [weak self] error in
                        self?.action.showToast.send(error.localizedDescription)
                        return Just(false)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                guard isSuccess else { return }
                NotificationCenter.default.post(name: .didCreateLink, object: nil, userInfo: ["folderID": (self?.state.selectedFolder.value?.id ?? -1)])
                self?.action.close.send(())
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3(self.state.selectedFolder
            .compactMap { $0 }, self.state.articleName, self.state.articleURLString)
        .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
        .sink { [weak self] (folder, articleName, articleURLString) in
            guard let self else { return }
            self.state.isActionButtonEnabled.send(self.isValid(folder: folder, articleName: articleName, articleURLString: articleURLString))
        }
        .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didSaveFolder)
            .sink { [weak self] _ in
                self?.getFolders()
            }
            .store(in: &cancellables)
    }
    
    func getFolders() {
        network.request(FolderEndpoint.getFolders)
            .tryMap { (data, _) -> [Folder] in
                let decoder = JSONDecoder()
                let folders = try decoder.decode([Folder].self, from: data, keyPath: "folderList")
                return folders
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] folders in
                self?.state.items.send([CopiedLinkFormItem(), TitleLinkFormItem(), PickFolderLinkFormItem(folders: folders)])
                guard let initialFolder = self?.initialFolder else {

                    self?.state.selectedFolder.send(folders.first { $0.type == .default })
                    return
                }
                self?.state.selectedFolder.send(folders.first { $0.id == initialFolder.id })
            }
            .store(in: &cancellables)
    }

    private func isValid(folder: Folder?, articleName: String, articleURLString: String) -> Bool {
        return (folder != nil && !articleName.isEmpty && !articleURLString.isEmpty)
    }
}

extension Notification.Name {

    static let didCreateLink = Notification.Name("didCreateLink")
}
