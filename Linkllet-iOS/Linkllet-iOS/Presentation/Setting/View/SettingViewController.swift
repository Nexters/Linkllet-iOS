//
//  SettingViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/26.
//

import UIKit
import Combine

final class SettingViewController: UIViewController {
    
    // MARK: Properties
    private var viewModel: SettingViewModel
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
        label.text = "설정"
        label.textAlignment = .center
        label.font = .PretendardB(size: 16)
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_x"), for: .normal)
        return button
    }()
    
    private let menuTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.bounces = false
        view.separatorStyle = .none
        return view
    }()
    
    // MARK: Life Cycle
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = SettingViewModel(networkService: NetworkService())
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraint()
        setPublisher()
        setDelegate()
    }
}

// MARK: - UI
extension SettingViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(menuTableView)
        view.addSubview(topBar)
        topBar.addSubview(topBarTitleLabel)
        topBar.addSubview(closeButton)
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
        
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Custom Methods
extension SettingViewController {
    
    private func setPublisher() {
        closeButton.tapPublisher
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func setDelegate() {
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.className)
    }
}

extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .init("EDEDED")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section != 2 ? 10 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PopupViewController(message: "해당 기능은 준비중입니다 :)")
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.menus.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menus[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.className, for: indexPath) as? MenuCell else { return UITableViewCell() }
        cell.setTitle(viewModel.menus[indexPath.section][indexPath.item])
        return cell
    }
}
