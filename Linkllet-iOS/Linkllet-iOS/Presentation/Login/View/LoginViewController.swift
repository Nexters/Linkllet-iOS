//
//  LoginViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/08/31.
//

import UIKit
import Combine
import KakaoSDKUser
import AuthenticationServices

final class LoginViewController: UIViewController {
    
    // MARK: Properties
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI Component
    private let logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Group 48096446")
        return view
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "소셜 계정으로 간편 가입하기"
        label.textColor = .gray_04
        label.font = .PretendardM(size: 12)
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()

    private let kakaoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_kakao"), for: .normal)
        return button
    }()
    
    private let appleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btn_apple"), for: .normal)
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인 건너뛰기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .PretendardM(size: 12)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.gray_01.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 14
        return button
    }()

    // MARK: Life Cycle
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = LoginViewModel(networkService: NetworkService())
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        setConstraints()
        setPublisher()
    }
}

// MARK: - UI
extension LoginViewController {
    
    private func setUI() {
        view.backgroundColor = .white
        [kakaoButton, appleButton].forEach { buttonStackView.addArrangedSubview($0) }
        [logoImageView, guideLabel, buttonStackView, skipButton].forEach { view.addSubview($0) }
    }
    
    private func setConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 265),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            guideLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.widthAnchor.constraint(equalToConstant: CGFloat(skipButton.titleLabel!.text!.count * 12))
        ])
    }
}

// MARK: - Custom Methods
extension LoginViewController {
    
    private func setPublisher() {
        
        kakaoButton.tapPublisher
            .sink { [weak self] _ in
                if (UserApi.isKakaoTalkLoginAvailable()) {
                    UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                        if error != nil {
                            UIViewController.showToast("문제가 발생하였습니다. 다시 시도해주세요.")
                        } else {
                            self?.getKakaoUserInfo()
                        }
                    }
                }
                else {
                    UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                        if error != nil {
                            UIViewController.showToast("문제가 발생하였습니다. 다시 시도해주세요.")
                        } else {
                            self?.getKakaoUserInfo()
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        appleButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let request = ASAuthorizationAppleIDProvider().createRequest()
                
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.presentationContextProvider = self
                controller.performRequests()
            }
            .store(in: &cancellables)
        
        skipButton.tapPublisher
            .sink { [weak self] _ in
                guard let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
                MemberInfoManager.default.registerMember(uuid)
                self?.dismiss(animated: true)
            }.store(in: &cancellables)
    }
}

// MARK: - Custom Methods
extension LoginViewController {
    
    private func getKakaoUserInfo() {
        UserApi.shared.me() {(user, error) in
            guard let uuid = user?.id else {
                UIViewController.showToast("문제가 발생하였습니다. 다시 시도해주세요.")
                return
            }
            MemberInfoManager.default.registerMember(String(uuid))
            self.dismiss(animated: true)
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        MemberInfoManager.default.registerMember(credential.user)
        self.dismiss(animated: true)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard error is ASAuthorizationError else { return }
        UIViewController.showToast("문제가 발생하였습니다. 다시 시도해주세요.")
     }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
