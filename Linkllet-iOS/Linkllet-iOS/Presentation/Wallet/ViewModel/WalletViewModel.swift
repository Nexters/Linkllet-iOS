//
//  WalletViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/18.
//

import Foundation
import Combine

final class WalletViewModel: ObservableObject {
    
    // MARK: Properties
    let folderSubject = CurrentValueSubject<[Folder], Never>([])
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    init(networkService: NetworkService) {
        self.network = networkService
    }
}

// MARK: - Custom Methods
extension WalletViewModel {
    
    func getFolders() {
        network.request(FolderEndpoint.getFolders)
            .tryMap { (data, _) -> [Folder] in
                let decoder = JSONDecoder()
                let folders = try decoder.decode([Folder].self, from: data, keyPath: "folderList")
                return folders
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] folders in
                self?.folderSubject.send(folders)
            }
            .store(in: &cancellables)
    }
}
