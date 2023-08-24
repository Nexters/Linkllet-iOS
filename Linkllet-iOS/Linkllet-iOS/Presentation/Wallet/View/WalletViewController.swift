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
    private let viewModel: WalletViewModel
    private var cancellables = Set<AnyCancellable>()
    private var collectionViewBottomConstraint: NSLayoutConstraint!
    private var collectionViewTopConstraint: NSLayoutConstraint!

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
        view.backgroundColor = .clear
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
        return view
    }()
    
    private let toastView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()

    private let toastLabel: UILabel = {
        let label = UILabel()
        label.text = "복사된 링크가 있어요!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private let toastSaveButton: UIButton = {
        let button = UIButton()
        button.setTitle("링크 저장하기", for: .normal)
        button.titleLabel?.font = .PretendardM(size: 12)
        button.setTitleColor(.white, for: .normal)
        button.setUnderline()
        return button
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [UIImage(named: "ico_rotation")!, UIImage(named: "ico_list")!])
        control.selectedSegmentIndex = 0
        return control
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
                guard isConnected, !MemberInfoManager.default.deviceIdPublisher.value.isEmpty else { return }
                self.viewModel.getFolders()
            }
            .store(in: &cancellables)

        MemberInfoManager.default.deviceIdPublisher
            .filter { !$0.isEmpty }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] deviceId in
                guard !deviceId.isEmpty else { return }
                self?.indicator.stopAnimating()
                self?.viewModel.getFolders()
            }
            .store(in: &self.cancellables)

        setUI()
        setConstraints()
        setDelegate()
        setBindings()
        setErrorView()
        checkPasteboard()
        setSegmentedControl()
    }
}

// MARK: - UI
extension WalletViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        [gearButton, searchButton, folderButton].forEach { buttonStackView.addArrangedSubview($0) }
        [buttonStackView, segmentedControl].forEach{ topBar.addSubview($0) }
        [backgroundImageView, folderCollectionView, countImageView, countLabel, floatingButton, topBar, errorView, indicator, toastView].forEach { view.addSubview($0) }
        [toastLabel, toastSaveButton].forEach { toastView.addSubview($0) }
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
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 18),
            segmentedControl.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 70),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
     
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 15),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 290)
        ])
        
        folderCollectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewTopConstraint = folderCollectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: backgroundImageView.frame.height + 40)
        collectionViewBottomConstraint = folderCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        NSLayoutConstraint.activate([
            collectionViewTopConstraint,
            collectionViewBottomConstraint,
            folderCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            folderCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
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

        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            errorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            toastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            toastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            toastView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 20),
            toastLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor)
        ])
        
        toastSaveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastSaveButton.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -20),
            toastSaveButton.centerYAnchor.constraint(equalTo: toastView.centerYAnchor)
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
        
        toastSaveButton.tapPublisher
            .sink { [weak self] _ in
                if let vc = LinkFormViewController.create(viewModel: LinkFormViewModel(pastedUrl: URL(string: self?.viewModel.pasteboard.value ?? ""))) {
                    vc.modalPresentationStyle = .overFullScreen
                    self?.present(vc, animated: true)
                }
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
        
        viewModel.selectedSegment
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self = self else { return }
                
                if index == 0 {
                    segmentedControl.setImage(UIImage(named: "ico_rotation")?.withTintColor(.black), forSegmentAt: 0)
                    segmentedControl.setImage(UIImage(named: "ico_list")?.withTintColor(.gray_03), forSegmentAt: 1)
                    
                    collectionViewBottomConstraint.constant = -117
                    collectionViewTopConstraint.constant = backgroundImageView.frame.height + 40
                    
                    let layout = CarouselLayout()
                    folderCollectionView.collectionViewLayout = layout

                    UIView.animate(withDuration: 0.2, animations: {
                        self.countImageView.alpha = 1
                        self.countLabel.alpha = 1
                        self.backgroundImageView.alpha = 1
                        self.folderCollectionView.layoutIfNeeded()
                    }, completion: { _ in
                        self.countImageView.isHidden = false
                        self.countLabel.isHidden = false
                    })
                } else {
                    segmentedControl.setImage(UIImage(named: "ico_rotation")?.withTintColor(.gray_03), forSegmentAt: 0)
                    segmentedControl.setImage(UIImage(named: "ico_list")?.withTintColor(.black), forSegmentAt: 1)
                    
                    collectionViewBottomConstraint.constant = -50
                    collectionViewTopConstraint.constant = 0
                    
                    let layout = UICollectionViewFlowLayout()
                    let topInset = view.safeAreaLayoutGuide.layoutFrame.height - topBar.frame.height - CGFloat(200 + 75 * (viewModel.folderSubject.value.count - 1) + 50)
                    layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: 200 - 75, right: 0)
                    layout.itemSize = CGSize(width: folderCollectionView.frame.width, height: 75)
                    layout.minimumLineSpacing = 0
                    folderCollectionView.collectionViewLayout = layout
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.countImageView.alpha = 0
                        self.countLabel.alpha = 0
                        self.backgroundImageView.alpha = 0.1
                        self.folderCollectionView.layoutIfNeeded()
                    }, completion: { _ in
                        self.countImageView.isHidden = true
                        self.countLabel.isHidden = true
                    })
                }
            }
            .store(in: &cancellables)
    }
    
    private func setSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    private func checkPasteboard() {
        if let storedString = UIPasteboard.general.string,
           let url = URL(string: storedString), UIApplication.shared.canOpenURL(url) {
            viewModel.pasteboard.send(storedString)
            self.toastView.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
                UIView.animate(withDuration: 0.3, animations: {
                    self.toastView.alpha = 0
                }, completion: { _ in
                    self.toastView.isHidden = true
                })
            }
        }
    }
}

// MARK: - @objc Methods
extension WalletViewController {
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.selectedSegment.send(sender.selectedSegmentIndex)
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
