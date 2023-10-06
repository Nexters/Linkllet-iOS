//
//  WalletViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/18.
//

import UIKit
import Combine

final class WalletViewController: UIViewController {
    
    // MARK: Properties
    private var viewModel: WalletViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: UI Component
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
        return view
    }()
    
    private let gearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_gear"), for: .normal)
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_search"), for: .normal)
        return button
    }()
    
    private let folderButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_folder"), for: .normal)
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_mainbg")
        return imageView
    }()
    
    private let folderCollectionView: UICollectionView = {
        let layout = CarouselLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false
        return view
    }()

    private let countImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ico_scroll")
        return imageView
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "3 Floders"
        label.font = .PretendardM(size: 16)
        return label
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_linksave"), for: .normal)
        return button
    }()

    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: .init(origin: .zero, size: .init(width: 50, height: 50)))
        view.center = self.view.center
        view.color = .blue
        view.style = .medium
        view.startAnimating()
        return view
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Life Cycle
    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = WalletViewModel(networkService: NetworkService())
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ReachabliltyManager.shared.isConnectedPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] isConnected in
                guard let self else { return }
                self.errorView.isHidden = isConnected
                guard isConnected, !MemberInfoManager.default.userIdentifierPublisher.value.isEmpty else { return }
                self.viewModel.getFolders()
            }
            .store(in: &cancellables)

        MemberInfoManager.default.userIdentifierPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userIdentifier in
                if userIdentifier.isEmpty {
                    let vc = LoginViewController(viewModel: LoginViewModel(networkService: NetworkService()))
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
                }else {
                    self?.indicator.stopAnimating()
                    self?.viewModel.getFolders()
                }
            }
            .store(in: &self.cancellables)

        setUI()
        setConstraints()
        setDelegate()
        setBindings()
        setErrorView()
    }
}

// MARK: - UI
extension WalletViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        [gearButton, searchButton, folderButton].forEach { buttonStackView.addArrangedSubview($0) }
        topBar.addSubview(buttonStackView)
        [backgroundImageView, folderCollectionView, countImageView, countLabel, floatingButton, topBar, errorView, indicator].forEach { view.addSubview($0) }
    }

    private func setErrorView() {

        let label = UILabel()
        label.numberOfLines = 0
        label.font = .PretendardB(size: 20)
        label.textAlignment = .center
        label.text = "네트워크에 연결해주세요:)"
        label.translatesAutoresizingMaskIntoConstraints = false

        errorView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setConstraints() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60)
        ])
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -18),
            buttonStackView.widthAnchor.constraint(equalToConstant: 128),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
     
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 15),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 290)
        ])
        
        folderCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            folderCollectionView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 15),
            folderCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            folderCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            folderCollectionView.heightAnchor.constraint(equalToConstant: 200 + 20 * 3)
        ])
        
        countImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countImageView.topAnchor.constraint(equalTo: folderCollectionView.bottomAnchor, constant: 15),
            countImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countImageView.heightAnchor.constraint(equalToConstant: 28),
            countImageView.widthAnchor.constraint(equalToConstant: 8)
        ])
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: countImageView.bottomAnchor, constant: 6),
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            floatingButton.heightAnchor.constraint(equalToConstant: 64),
            floatingButton.widthAnchor.constraint(equalToConstant: 64)
        ])

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            errorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Custom Methods
extension WalletViewController {
    
    private func setDelegate() {
        folderCollectionView.register(FolderCell.self, forCellWithReuseIdentifier: FolderCell.className)
        folderCollectionView.delegate = self
        folderCollectionView.dataSource = self
    }
    
    private func setBindings() {
        viewModel.folderSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] folders in
                self?.folderCollectionView.reloadData()
                self?.countLabel.text = "\(folders.count) Folders"
            })
            .store(in: &cancellables)

        floatingButton.tapPublisher
            .sink { [weak self] _ in
                if let vc = LinkFormViewController.create(viewModel: LinkFormViewModel()) {
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
                }
            }
            .store(in: &cancellables)
        
        gearButton.tapPublisher
            .sink { [weak self] _ in
                let vc = SettingViewController(viewModel: SettingViewModel(networkService: NetworkService()))
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        
        searchButton.tapPublisher
            .sink { [weak self] _ in
                let vc = SearchViewController(viewModel: SearchViewModel(networkService: NetworkService()))
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        
        folderButton.tapPublisher
            .sink { [weak self] _ in
                let vc = FolderFormViewController(viewModel: FolderFormViewModel(networkService: NetworkService(), formType: .create))
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }
            .store(in: &cancellables)

        viewModel.showIndicator
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.indicator.startAnimating()
            }
            .store(in: &cancellables)

        viewModel.hideIndicator
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.indicator.stopAnimating()
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
                                 UIPasteboard.general.publisher(for: \.string)
        )
        .debounce(for: 0.5, scheduler: DispatchQueue.main)
        .sink { (_, storedString) in
            guard let url = URL(string: storedString ?? "") else { return }
            if UIApplication.shared.canOpenURL(url), !MemberInfoManager.default.userIdentifierPublisher.value.isEmpty {
                UIViewController.showToast("복사된 링크가 있어요!", buttonTitleString: "링크 저장하기") {
                    if let vc = LinkFormViewController.create(viewModel: LinkFormViewModel(pastedUrl: url)) {
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: true)
                        UIPasteboard.general.string = ""
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource
extension WalletViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.folderSubject.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.className, for: indexPath) as? FolderCell else { return UICollectionViewCell() }
        cell.setFolderCell(indexPath.item, viewModel.folderSubject.value[indexPath.item])
        cell.clipsToBounds = false
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension WalletViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = LinkListViewController(viewModel: LinkListViewModel(networkService: NetworkService(), folder: viewModel.folderSubject.value[indexPath.item]))
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - LinkListViewControllerDelegate
extension WalletViewController: LinkListViewControllerDelegate {
    
    func didDeleteFolder(_ viewController: LinkListViewController) {
        viewModel.getFolders()
        UIViewController.showToast("폴더를 삭제했어요")
    }
    
    func didDeleteLink(_ viewController: LinkListViewController) {
        viewModel.getFolders()
    }
}
