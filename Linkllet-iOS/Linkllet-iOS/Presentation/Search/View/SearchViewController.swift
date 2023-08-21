//
//  SearchViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/08/18.
//

import UIKit
import Combine
import SafariServices

final class SearchViewController: UIViewController {
    
    // MARK: Properties
    private var viewModel: SearchViewModel
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
    
    private let topBarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "검색"
        label.textAlignment = .center
        label.font = .PretendardB(size: 16)
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_x"), for: .normal)
        return button
    }()
    
    private let searchInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray_01
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let searchResultLabel: UILabel = {
        let label = UILabel()
        label.text = "링크 검색 결과 (0)"
        label.font = .PretendardB(size: 14)
        label.isHidden = true
        return label
    }()
    
    private let searchInputTextField: UITextField = {
        let textField = UITextField()
        textField.font = .PretendardM(size: 14)
        textField.placeholder = "검색어를 입력해 주세요"
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_search"), for: .normal)
        return button
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다"
        label.font = .PretendardM(size: 14)
        label.textColor = .gray_04
        label.isHidden = true
        return label
    }()
    
    private let linkCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    // MARK: Life Cycle
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = SearchViewModel(networkService: NetworkService())
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraint()
        addTargets()
        setDelegate()
        setPublisher()
        setBindings()
    }
}

// MARK: - UI
extension SearchViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(topBar)
        topBar.addSubview(topBarTitleLabel)
        topBar.addSubview(closeButton)
        view.addSubview(searchInputView)
        searchInputView.addSubview(searchInputTextField)
        searchInputView.addSubview(searchButton)
        view.addSubview(searchResultLabel)
        view.addSubview(linkCollectionView)
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
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -18),
            closeButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        searchInputView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchInputView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 20),
            searchInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchInputView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        searchInputTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchInputTextField.centerYAnchor.constraint(equalTo: searchInputView.centerYAnchor),
            searchInputTextField.leadingAnchor.constraint(equalTo: searchInputView.leadingAnchor, constant: 20),
            searchInputTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: 10)
        ])
        
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchButton.centerYAnchor.constraint(equalTo: searchInputView.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: searchInputView.trailingAnchor, constant: -20),
            searchButton.heightAnchor.constraint(equalToConstant: 24),
            searchButton.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        searchResultLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchResultLabel.topAnchor.constraint(equalTo: searchInputView.bottomAnchor, constant: 30),
            searchResultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        
        linkCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            linkCollectionView.topAnchor.constraint(equalTo: searchResultLabel.bottomAnchor, constant: 20),
            linkCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            linkCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            linkCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: linkCollectionView.centerYAnchor)
        ])
    }
}

// MARK: - Custom Methods
extension SearchViewController {
    
    private func addTargets() {
        searchInputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setDelegate() {
        searchInputTextField.delegate = self
        linkCollectionView.register(LinkCell.self, forCellWithReuseIdentifier: LinkCell.className)
        linkCollectionView.delegate = self
        linkCollectionView.dataSource = self
    }
    
    private func setPublisher() {
        closeButton.tapPublisher
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        searchButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel.getLinks()
            }
            .store(in: &cancellables)
    }
    
    private func setBindings() {
        viewModel.state.linksSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.linkCollectionView.reloadData()
                self?.searchResultLabel.text = "링크 검색 결과 (\(data.count))"
                self?.searchResultLabel.isHidden = data.isEmpty
            })
            .store(in: &cancellables)
        
        viewModel.action.hideEmptyLabel
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                self?.emptyLabel.isHidden = state
            })
            .store(in: &cancellables)
        
        viewModel.action.showToast
            .receive(on: DispatchQueue.main)
            .sink { reason in
                UIViewController.showToast(reason)
            }
            .store(in: &cancellables)
    }
}

// MARK: - @objc Methods
extension SearchViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel.state.inputSubject.send(textField.text!)
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.getLinks()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.state.linksSubject.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCell.className, for: indexPath) as? LinkCell else { return UICollectionViewCell() }
        cell.setLinkCell(viewModel.state.linksSubject.value[indexPath.item], isHiddenMoreButton: true)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
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
extension SearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let linkUrl = viewModel.state.linksSubject.value[indexPath.item].url else { return }

        if ["http", "https"].contains(linkUrl.scheme?.lowercased() ?? "") {
            let safariViewController = SFSafariViewController(url: linkUrl)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            UIViewController.showToast("URL을 확인해주세요")
        }
    }
}
