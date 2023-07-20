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

    func showToast(_ message : String) {
        
        let toastView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0, alpha: 0.8)
            view.layer.cornerRadius = 12
            return view
        }()
    
        let toastLabel: UILabel = {
            let label = UILabel()
            label.text = message
            label.textColor = .init("FFFFFF")
            label.font = UIFont.systemFont(ofSize: 12)
            return label
        }()
            
        view.addSubview(toastView)
        toastView.addSubview(toastLabel)
        
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            toastView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            toastView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            toastView.heightAnchor.constraint(equalToConstant: 60)
        ])

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: toastView.centerXAnchor),
            toastLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor)
        ])
            
        UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseInOut, animations: {
            toastView.alpha = 0.0
        }, completion: {(isCompleted) in
            toastView.removeFromSuperview()
        })
    }
}
