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
    
    private let topBarTitleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_logo")
        return imageView
    }()
    
    private let gearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_gear"), for: .normal)
        return button
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_mainbg")
        return imageView
    }()
    
    private let folderCollectionView:  UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_linksave"), for: .normal)
        return button
    }()

    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: .init(origin: .zero, size: .init(width: 50, height: 50)))
        view.center = view.center
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
                guard isConnected, MemberInfoManager.default.isMemberPublisher.value else { return }
                self.viewModel.getFolders()
            }
            .store(in: &cancellables)

        MemberInfoManager.default.isMemberPublisher
            .filter { $0 }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isMember in
                guard isMember else { return }
                self?.indicator.stopAnimating()
                self?.viewModel.getFolders()
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
        view.addSubview(backgroundImageView)
        view.addSubview(folderCollectionView)
        view.addSubview(floatingButton)
        view.addSubview(topBar)
        view.addSubview(errorView)
        topBar.addSubview(topBarTitleImage)
        topBar.addSubview(gearButton)
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
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60)
        ])
        
        topBarTitleImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBarTitleImage.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            topBarTitleImage.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -18)
        ])
        
        gearButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gearButton.centerYAnchor.constraint(equalTo: topBarTitleImage.centerYAnchor),
            gearButton.rightAnchor.constraint(equalTo: topBar.rightAnchor, constant: -18)
        ])
     
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 25),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        
        folderCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            folderCollectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            folderCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            folderCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            folderCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
                guard let self = self else { return }
                let topInset = self.view.safeAreaLayoutGuide.layoutFrame.height - CGFloat(min(folders.count, 3) * 75 + 180 + 60)
                self.folderCollectionView.contentInset.top = topInset
                self.folderCollectionView.reloadData()
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
        
        folderCollectionView.publisher(for: \.contentOffset)
            .map { max(min(-$0.y, self.folderCollectionView.contentInset.top), 0) }
            .removeDuplicates()
            .sink { [weak self] offsetY in
                self?.backgroundImageView.layer.opacity = Float(offsetY / 250)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource
extension WalletViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.folderSubject.value.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.className, for: indexPath) as? FolderCell else { return UICollectionViewCell() }
        if indexPath.item == 0 {
            cell.setPlusCell()
        } else {
            cell.setFolderCell(indexPath.item, viewModel.folderSubject.value[indexPath.item - 1])
        }
        cell.clipsToBounds = false
        cell.layer.zPosition = CGFloat(indexPath.item)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WalletViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width - 10, height: 75)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionViewDelegate
extension WalletViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let vc = FolderFormViewController(viewModel: FolderFormViewModel(networkService: NetworkService(), formType: .create))
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            let vc = LinkListViewController(viewModel: LinkListViewModel(networkService: NetworkService(), folder: viewModel.folderSubject.value[indexPath.item - 1]))
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = scrollView.contentOffset.y < 0
    }
}

// MARK: - LinkListViewControllerDelegate
extension WalletViewController: LinkListViewControllerDelegate {
    
    func didDeleteFolder(_ viewController: LinkListViewController) {
        viewModel.getFolders()
        showToast("폴더를 삭제했어요")
    }
    
    func didDeleteLink(_ viewController: LinkListViewController) {
        viewModel.getFolders()
    }
}
