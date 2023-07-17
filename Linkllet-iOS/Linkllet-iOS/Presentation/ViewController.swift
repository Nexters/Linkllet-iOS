//
//  ViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/07.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let vc = LinkFormViewController.create(viewModel: LinkFormViewModel()) {
            present(vc, animated: true)
        }
        
    }
}

