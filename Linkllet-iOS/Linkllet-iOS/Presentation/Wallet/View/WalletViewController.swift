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
    
    var collectionViewTopConstraint: NSLayoutConstraint!
    var initialTopAnchorConstant: CGFloat = 0

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
        view.bounces = false
        view.showsVerticalScrollIndicator = false
        view.isScrollEnabled = false
        return view
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_linksave"), for: .normal)
        return button
    }()
    
    // MARK: Life Cycle
    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = WalletViewModel()
        super.init(coder: coder)
        setUI()
        setConstraints()
        setDelegate()
        setGesture()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        setDelegate()
        setGesture()
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
        topBar.addSubview(topBarTitleImage)
        topBar.addSubview(gearButton)
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
        let screenHeight: Int = Int(view.bounds.height)
        if viewModel.cardSubject.value.count >= 3 {
            initialTopAnchorConstant = CGFloat(screenHeight * 728 / 812 - 60 - (3 * 75 + 180))
        } else {
            initialTopAnchorConstant = CGFloat(screenHeight * 728 / 812 - 60 - (viewModel.cardSubject.value.count * 75 + 180))
        }
        collectionViewTopConstraint = folderCollectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: initialTopAnchorConstant)
        collectionViewTopConstraint.isActive = true
        NSLayoutConstraint.activate([
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
    }
}

// MARK: - Custom Methods
extension WalletViewController {
    
    private func setDelegate() {
        folderCollectionView.register(FolderCell.self, forCellWithReuseIdentifier: FolderCell.className)
        folderCollectionView.delegate = self
        folderCollectionView.dataSource = self
    }
    
    private func setGesture() {
        let panGestureRecongnizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_ :)))
        panGestureRecongnizer.delegate = self
        panGestureRecongnizer.delaysTouchesBegan = false
        panGestureRecongnizer.delaysTouchesEnded = false
        folderCollectionView.addGestureRecognizer(panGestureRecongnizer)
    }
}

// MARK: - @objc Methods
extension WalletViewController {
    
    @objc func panGestureHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let collectionView = gestureRecognizer.view else { return }

        let translation = gestureRecognizer.translation(in: collectionView)

        if gestureRecognizer.state == .began {
            initialTopAnchorConstant = collectionViewTopConstraint.constant
        }

        let newConstant = initialTopAnchorConstant + translation.y
        
        var maxHeight: CGFloat
        if viewModel.cardSubject.value.count >= 3 {
            maxHeight = view.safeAreaLayoutGuide.layoutFrame.height - CGFloat(3 * 75 + 180 + 60)
        } else {
            maxHeight = view.safeAreaLayoutGuide.layoutFrame.height - CGFloat(viewModel.cardSubject.value.count * 75 + 180 + 60)
        }

        let minAnchorConstant: CGFloat = -(CGFloat(viewModel.cardSubject.value.count * 75 + 180 + 60) - view.safeAreaLayoutGuide.layoutFrame.height)
        let maxAnchorConstant: CGFloat = maxHeight
        
        collectionViewTopConstraint.constant = max(min(newConstant, maxAnchorConstant), minAnchorConstant)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension WalletViewController: UIGestureRecognizerDelegate {
 
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
           return true
       }
}

// MARK: - UICollectionViewDataSource
extension WalletViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.cardSubject.value.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCell.className, for: indexPath) as? FolderCell else { return UICollectionViewCell() }
        if indexPath.item == 0 {
            cell.setPlusCell()
        } else {
            cell.setFolderCell(indexPath.item, viewModel.cardSubject.value[indexPath.item - 1])
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension WalletViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 365, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -105
    }
}

// MARK: - UICollectionViewDelegate
extension WalletViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // TODO: - 폴더 추가 뷰 연결
        } else {
            // TODO: - 폴더 내 링크 목록 뷰 연결
            print(indexPath.item - 1, viewModel.cardSubject.value[indexPath.item - 1])
        }
    }
}
