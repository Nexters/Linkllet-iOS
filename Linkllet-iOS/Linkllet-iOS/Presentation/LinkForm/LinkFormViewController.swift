//
//  LinkFormViewController.swift
//  Linkllet-iOS
//
//  Created by 최동규 on 2023/07/17.
//

import Combine
import UIKit

final class LinkFormViewController: UIViewController {

    @IBOutlet private weak var closeButton: UIButton!
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: LinkFormViewModel

    init?(coder: NSCoder, viewModel: LinkFormViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("This viewController must be init with viewModel.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPublisher()
    }
}

private extension LinkFormViewController {

    func setPublisher() {
        closeButton.tapPublisher
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
}

extension LinkFormViewController {

    static func create(viewModel: LinkFormViewModel) -> LinkFormViewController? {
        let storyboard = UIStoryboard(name: "LinkForm", bundle: Bundle(for: LinkFormViewController.self))
        let viewContoller = storyboard.instantiateViewController(
            identifier: LinkFormViewController.className,
            creator: { coder -> LinkFormViewController? in
                return LinkFormViewController(coder: coder, viewModel: viewModel)})
            return viewContoller
    }
}

final class LinkFormViewModel {

}

extension UIViewController {

    static var className: String {
        return String(describing: Self.self)
    }
}
