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


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let vc = LinkFormViewController.create(viewModel: LinkFormViewModel()) {
            present(vc, animated: true)
        }
        
    }
}

