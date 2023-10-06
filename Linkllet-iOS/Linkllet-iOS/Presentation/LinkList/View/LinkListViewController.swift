//
//  LinkListViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/20.
//

import UIKit
import Combine
import SafariServices

protocol LinkListViewControllerDelegate: NSObject {
    func didDeleteFolder(_ viewController: LinkListViewController)
    func didDeleteLink(_ viewController: LinkListViewController)
}

final class LinkListViewController: UIViewController {
    
    // MARK: Properties
    private var viewModel: LinkListViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: LinkListViewControllerDelegate?
    
    // MARK: UI Component
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
        return view
    }()

    private let topBarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "개발링크들"
        label.textAlignment = .center
        label.font = .PretendardB(size: 16)
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_back"), for: .normal)
        return button
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_edit"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "링크를 저장해 주세요"
        label.font = .PretendardM(size: 14)
        label.textColor = .gray_04
        return label
    }()
    
    private let linkCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 80, right: 0)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_linksave"), for: .normal)
        return button
    }()
    
    // MARK: Life Cycle
    init(viewModel: LinkListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = LinkListViewModel(networkService: NetworkService(), folder: Folder(id: 0, name: "", type: .personalized, size: 0))
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraint()
        setDelegate()
        setPublisher()
        setBindings()
        setTitle()
        viewModel.getLinks()
    }
}

// MARK: - UI
extension LinkListViewController {

    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(topBar)
        topBar.addSubview(topBarTitleLabel)
        topBar.addSubview(backButton)
        topBar.addSubview(editButton)
        view.addSubview(linkCollectionView)
        view.addSubview(floatingButton)
        view.addSubview(emptyLabel)

        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in

            let closeAction = UIContextualAction(
                style: .destructive,
                title: "삭제하기",
                handler: { [weak self] _, _, _ in
                    guard let self = self else { return }
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }

                        let vc = PopupViewController(message: "링크를 삭제할건가요?", confirmAction: {
                            self.viewModel.deleteLink(articleID: self.viewModel.linksSubject.value[indexPath.item].id, completion: {
                                UIViewController.showToast("링크를 삭제했어요")
                                self.delegate?.didDeleteLink(self)
                            })
                        }, cancelAction: { [weak self] in
                            self?.linkCollectionView.reloadItems(at: [indexPath])
                        })
                        vc.modalPresentationStyle = .overFullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        self.present(vc, animated: true, completion: nil)
                    }

                }
            )
            return UISwipeActionsConfiguration(actions: [closeAction])
        }
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        linkCollectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private func setConstraint() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 60)
        ])

        topBarTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBarTitleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            topBarTitleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])

        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 18),
            backButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -18),
            editButton.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        linkCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            linkCollectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            linkCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            linkCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            linkCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            floatingButton.heightAnchor.constraint(equalToConstant: 64),
            floatingButton.widthAnchor.constraint(equalToConstant: 64)
        ])
        
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: linkCollectionView.centerYAnchor)
        ])
    }
}

// MARK: - Custom Methods
extension LinkListViewController {
    
    private func setDelegate() {
        linkCollectionView.register(LinkCell.self, forCellWithReuseIdentifier: LinkCell.className)
        linkCollectionView.delegate = self
        linkCollectionView.dataSource = self
    }
    
    private func setPublisher() {
        backButton.tapPublisher
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        editButton.tapPublisher
            .sink { [weak self] _ in
                let delete = UIAction(title: "폴더 삭제하기", handler: { _ in
                    let vc = PopupViewController(message: "폴더를 삭제할건가요?", confirmAction: {
                        self?.viewModel.deleteFolder(completion: {
                            self?.delegate?.didDeleteFolder(self!)
                            self?.navigationController?.popViewController(animated: true)
                        })
                        self?.navigationController?.popViewController(animated: true)
                    })
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self?.present(vc, animated: true, completion: nil)
                })
                
                let edit = UIAction(title: "폴더 수정하기", handler: { _ in
                    if let folder = self?.viewModel.folder {
                        let vc = FolderFormViewController(viewModel: FolderFormViewModel(networkService: NetworkService(), formType: .edit, folder: folder))
                        vc.modalPresentationStyle = .overFullScreen
                        self?.present(vc, animated: true, completion: nil)
                    }
                })
                
                if self?.viewModel.folder.type == .default {
                    self?.editButton.menu = UIMenu(children: [edit])
                } else {
                    self?.editButton.menu = UIMenu(children: [edit, delete])
                }
            }
            .store(in: &cancellables)
        
        floatingButton.tapPublisher
            .sink { [weak self] _ in
                guard let folder = self?.viewModel.folder else {
                    if let vc = LinkFormViewController.create(viewModel: LinkFormViewModel()) {
                        vc.modalPresentationStyle = .overFullScreen
                        self?.present(vc, animated: true)
                    }
                    return
                }
                let viewModel = LinkFormViewModel(initialFolder: folder)
                if let vc = LinkFormViewController.create(viewModel: viewModel) {
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
                }

            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didSaveFolder)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo else { return }
                if let name = userInfo["folderName"] as? String {
                    self?.topBarTitleLabel.text = name
                }
            }
            .store(in: &cancellables)
    }
    
    private func setBindings() {
        viewModel.linksSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.linkCollectionView.reloadData()
                self?.emptyLabel.isHidden = data.count != 0
        })
            .store(in: &cancellables)
    }
    
    private func setTitle() {
        topBarTitleLabel.text = viewModel.folder.name
    }
}

// MARK: - UICollectionViewDataSource
extension LinkListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.linksSubject.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.className, for: indexPath) as? LinkCell else { return UICollectionViewCell() }
        cell.setLinkCell(viewModel.linksSubject.value[indexPath.item])
        cell.deleteLinkClosure = {
            let vc = PopupViewController(message: "링크를 삭제할건가요?", confirmAction: {
                self.viewModel.deleteLink(articleID: self.viewModel.linksSubject.value[indexPath.item].id, completion: {
                    UIViewController.showToast("링크를 삭제했어요")
                    self.delegate?.didDeleteLink(self)
                })
            })
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LinkListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width - 36, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - UICollectionViewDelegate
extension LinkListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let linkUrl = viewModel.linksSubject.value[indexPath.item].url else { return }
        
        if ["http", "https"].contains(linkUrl.scheme?.lowercased() ?? "") {
            let safariViewController = SFSafariViewController(url: linkUrl)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            UIViewController.showToast("URL을 확인해주세요")
        }
    }
}
