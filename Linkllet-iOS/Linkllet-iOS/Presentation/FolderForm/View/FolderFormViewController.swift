//
//  FolderFormViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/17.
//

import UIKit
import Combine

protocol FolderFormViewControllerDelegate: NSObject {
    func didSaveFolder(_ viewController: FolderFormViewController)
}

class FolderFormViewController: UIViewController {
    
    // MARK: Properties
    private var viewModel: FolderFormViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: FolderFormViewControllerDelegate?
    
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
        label.text = "폴더 추가하기"
        label.textAlignment = .center
        label.font = .PretendardB(size: 16)
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ico_x"), for: .normal)
        return button
    }()
    
    private let folderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "폴더 제목"
        label.textAlignment = .center
        label.font = .PretendardB(size: 14)
        return label
    }()
    
    private let inputTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .init("F4F4F4")
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let inputTitleTextField: UITextField = {
        let textField = UITextField()
        textField.font = .PretendardM(size: 14)
        textField.placeholder = "제목을 입력해 주세요"
        return textField
    }()
    
    private let inputGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "※ 최대 10자까지 입력할 수 있어요."
        label.textColor = .init("7B7B7B")
        label.font = .PretendardM(size: 12)
        return label
    }()
    
    private let inputCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10"
        label.textColor = .init("7B7B7B")
        label.font = .PretendardM(size: 12)
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .init("E9E9E9")
        button.setTitle("저장하기", for: .normal)
        button.titleLabel?.font = .PretendardM(size: 14)
        button.setTitleColor(.init("878787"), for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: Life Cycle
    init(viewModel: FolderFormViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = FolderFormViewModel(networkService: NetworkService())
        super.init(coder: coder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        addTargets()
        setDelegate()
        setPublisher()
        setBindings()
    }
}

// MARK: - UI
extension FolderFormViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(topBar)
        topBar.addSubview(topBarTitleLabel)
        topBar.addSubview(closeButton)
        view.addSubview(folderTitleLabel)
        view.addSubview(inputTitleView)
        inputTitleView.addSubview(inputTitleTextField)
        view.addSubview(inputGuideLabel)
        view.addSubview(inputCountLabel)
        view.addSubview(confirmButton)
    }
    
    private func setConstraints() {
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
        
        folderTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            folderTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            folderTitleLabel.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 30)
        ])
        
        inputTitleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputTitleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputTitleView.topAnchor.constraint(equalTo: folderTitleLabel.bottomAnchor, constant: 16),
            inputTitleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputTitleView.heightAnchor.constraint(equalToConstant: 49)
        ])
        
        inputTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputTitleTextField.leadingAnchor.constraint(equalTo: inputTitleView.leadingAnchor, constant: 20),
            inputTitleTextField.centerYAnchor.constraint(equalTo: inputTitleView.centerYAnchor)
        ])
        
        inputGuideLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputGuideLabel.topAnchor.constraint(equalTo: inputTitleView.bottomAnchor, constant: 10),
            inputGuideLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        
        inputCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputCountLabel.topAnchor.constraint(equalTo: inputTitleView.bottomAnchor, constant: 10),
            inputCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - Custom Methods
extension FolderFormViewController {
    
    private func addTargets() {
        inputTitleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setDelegate() {
        inputTitleTextField.delegate = self
    }
    
    private func setPublisher() {
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
        
        confirmButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel.createFolder()
            }
            .store(in: &cancellables)
    }
    
    private func setBindings() {
        viewModel.inputStatusSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { errorStatus in
                self.setInputView(errorStatus)
        })
            .store(in: &cancellables)
    }
    
    private func setConfirmButton(_ input: String) {
        if input.count > 0 {
            confirmButton.backgroundColor = .init("000000")
            confirmButton.setTitleColor(.init("ffffff"), for: .normal)
        } else {
            confirmButton.backgroundColor = .init("E9E9E9")
            confirmButton.setTitleColor(.init("878787"), for: .normal)
        }
    }
    
    private func inputCountLabel(_ input: String) {
        inputCountLabel.text = "\(input.count)/10"
    }
    
    private func setInputView(_ status: InputStatus) {
        switch status {
        case .normal:
            inputTitleView.layer.borderWidth = 0
        case .saved:
            inputTitleView.layer.borderWidth = 0
            delegate?.didSaveFolder(self)
            dismiss(animated: true)
        case .emptyError:
            inputTitleView.layer.borderWidth = 2
            inputTitleView.layer.borderColor = UIColor.init("F34A3F").cgColor
            showToast("폴더 제목을 입력해 주세요")
        case .duplicateError:
            inputTitleView.layer.borderWidth = 2
            inputTitleView.layer.borderColor = UIColor.init("F34A3F").cgColor
            showToast("폴더 제목이 중복됩니다")
        }
    }
}

// MARK: - @objc Methods
extension FolderFormViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        setConfirmButton(textField.text!)
        inputCountLabel(textField.text!)
        viewModel.titleSubject.send(textField.text!)
    }
}

// MARK: - UITextFieldDelegate
extension FolderFormViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       if let char = string.cString(using: String.Encoding.utf8) {
              let isBackSpace = strcmp(char, "\\b")
              if isBackSpace == -92 {
                  return true
              }
        }
        guard textField.text!.count < 10 else { return false }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}
