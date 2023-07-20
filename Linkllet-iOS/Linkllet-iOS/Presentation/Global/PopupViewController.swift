//
//  PopupViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/20.
//

import UIKit
import Combine

class PopupViewController: UIViewController {
    
    // MARK: Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI Component
    private let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .init("FFFFFF")
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .PretendardM(size: 12)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    private let lineView: UIView = {
        let line = UIView()
        line.backgroundColor = .init("EDEDED")
        return line
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_x"), for: .normal)
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_o"), for: .normal)
        return button
    }()

    // MARK: Life Cycle
    init(message: String) {
        super.init(nibName: nil, bundle: nil)
        self.setMessage(message)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setMessage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        setPublisher()
    }
}

// MARK: - UI
extension PopupViewController {
    
    private func setUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(popupView)
        popupView.addSubview(messageLabel)
        popupView.addSubview(lineView)
        popupView.addSubview(closeButton)
        popupView.addSubview(confirmButton)
    }
    
    private func setConstraints() {
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.heightAnchor.constraint(equalToConstant: 173),
            popupView.widthAnchor.constraint(equalToConstant: 280)
        ])
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -12),
            messageLabel.heightAnchor.constraint(equalToConstant: 108)
        ])
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 12),
            closeButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 12),
            confirmButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -12),
            confirmButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
}

// MARK: - Custom Methods
extension PopupViewController {
    
    private func setPublisher() {
        closeButton.tapPublisher
            .sink { [weak self] _ in
                self?.dismiss(animated: false)
            }
            .store(in: &cancellables)
        confirmButton.tapPublisher
            .sink { [weak self] _ in
                self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }
    
    private func setMessage(_ message: String = "작성한 내용이 삭제됩니다.\n작성을 취소할건가요?") {
        messageLabel.text = message
    }
}
