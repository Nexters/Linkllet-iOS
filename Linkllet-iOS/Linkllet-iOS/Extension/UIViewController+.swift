//
//  NSObject+.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/17.
//

import UIKit

extension UIViewController {

    static var className: String {
        return String(describing: Self.self)
    }

    static func showToast(_ message : String, rightButtonLabel: String = "") {

        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        let toastView: UIView = {
            let view = UIView()
            view.backgroundColor = .black.withAlphaComponent(0.8)
            view.layer.cornerRadius = 12
            return view
        }()
    
        let toastLabel: UILabel = {
            let label = UILabel()
            label.text = message
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12)
            return label
        }()
        
        let saveButton: UIButton = {
            let button = UIButton()
            button.setTitle(rightButtonLabel, for: .normal)
            button.titleLabel?.font = .PretendardM(size: 12)
            button.setTitleColor(.white, for: .normal)
            button.setUnderline()
            button.isHidden = rightButtonLabel.isEmpty
            return button
        }()
            
        keyWindow.addSubview(toastView)
        toastView.addSubview(toastLabel)
        toastView.addSubview(saveButton)
        
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.topAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.topAnchor, constant: 20),
            toastView.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor, constant: 24),
            toastView.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor, constant: -24),
            toastView.heightAnchor.constraint(equalToConstant: 60)
        ])

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        if rightButtonLabel.isEmpty {
            NSLayoutConstraint.activate([
                toastLabel.centerXAnchor.constraint(equalTo: toastView.centerXAnchor),
                toastLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                toastLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 20),
                toastLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor)
            ])
        }
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: toastView.centerYAnchor)
        ])
            
        UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseInOut, animations: {
            toastView.alpha = 0.0
        }, completion: {(isCompleted) in
            toastView.removeFromSuperview()
        })
    }
}
