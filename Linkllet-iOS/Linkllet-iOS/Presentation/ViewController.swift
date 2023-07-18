//
//  ViewController.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/07.
//

import Combine
import UIKit

class ViewController: UIViewController {

    let memberInfoManager: MemberInfoManager

    init (memberInfoManager: MemberInfoManager, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.memberInfoManager = memberInfoManager
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("This viewController must be init with memberInfoManager")
    }

    private var cancellables = Set<AnyCancellable>()

    private let testNetwork = NetworkService()
    override func viewDidLoad() {
        super.viewDidLoad()

        // 멤버 회원가입 예외처리, 추후 UI 수정


        if !memberInfoManager.isMemberPublisher.value {
            self.view.isUserInteractionEnabled = false
            memberInfoManager.registerMember()

            memberInfoManager.isMemberPublisher
                .removeDuplicates()
                .filter { $0 }
                .prefix(1)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isMember in
                    self?.view.isUserInteractionEnabled = false
                }
                .store(in: &cancellables)
        }

        testNetwork.request(FolderEndpoint.getFolders)
            .tryMap { (data, _) in
                let decoder = JSONDecoder()
                let folders = try decoder.decode([Folder].self, from: data, keyPath: "folderList")
                return folders
            }
//          replaceError가 아니라  .catch, completion으로 핸들링하는법 고민
            .replaceError(with: [])
            .sink { folders in
                print(folders)
            }
            .store(in: &cancellables)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let vc = LinkFormViewController.create(viewModel: LinkFormViewModel()) {
            present(vc, animated: true)
        }

    }
}

