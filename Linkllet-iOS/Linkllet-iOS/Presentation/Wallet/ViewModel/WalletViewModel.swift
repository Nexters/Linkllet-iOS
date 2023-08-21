//
//  WalletViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/18.
//

import Foundation
import Combine

final class WalletViewModel {
    
    // MARK: Properties
    let folderSubject = CurrentValueSubject<[Folder], Never>([])
    let pasteboard = CurrentValueSubject<String, Never>("")
    let showIndicator = PassthroughSubject<Void, Never>()
    let hideIndicator = PassthroughSubject<Void, Never>()
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    init(networkService: NetworkService) {
        self.network = networkService
        setPublisher()
    }
}

// MARK: - Custom Methods
extension WalletViewModel {
    
    func getFolders() {
        showIndicator.send(())
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
                self?.hideIndicator.send(())
            }
            .store(in: &cancellables)
    }
}

private extension WalletViewModel {
    func setPublisher() {
        NotificationCenter.default.publisher(for: .didCreateLink)
            .sink { [weak self] notification in
                guard let self else { return }
                let folderID = (notification.userInfo?["folderID"] as? Int64) ?? -1
                var newFolders = self.folderSubject.value
                guard let folderIndex = newFolders.firstIndex(where: { $0.id == folderID }) else { return }
                var folder = newFolders[folderIndex]
                folder.size += 1
                newFolders[folderIndex] = folder
                self.folderSubject.send(newFolders)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didSaveFolder)
            .sink { [weak self] notification in
                guard let self else { return }
                self.getFolders()
            }
            .store(in: &cancellables)
    }
}
