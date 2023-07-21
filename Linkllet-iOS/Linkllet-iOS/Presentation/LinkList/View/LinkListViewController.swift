//
//  LinkListViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/20.
//

import UIKit
import Combine

protocol LinkListViewControllerDelegate: NSObject {
    func didDeleteFolder(_ viewController: LinkListViewController)
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
        label.textColor = .init("878787")
        return label
    }()
    
    private let linkCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 80, right: 0)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.bounces = false
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
        self.viewModel = LinkListViewModel(networkService: NetworkService(), folder: Folder(id: 0, name: "", type: .personalized))
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
                self?.editButton.menu = UIMenu(children: [delete])
            }
            .store(in: &cancellables)
        
        floatingButton.tapPublisher
            .sink { [weak self] _ in
                if let vc = LinkFormViewController.create(viewModel: LinkFormViewModel()) {
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setBindings() {
        viewModel.linksSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { data in
                self.linkCollectionView.reloadData()
                self.emptyLabel.isHidden = data.count != 0
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
        // TODO: - 링크로 이동
    }
}
