//
//  LinkListViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/20.
//

import Foundation
import Combine

final class LinkListViewModel: ObservableObject {
    
    // MARK: Properties
    let folder: Folder
    let linksSubject = CurrentValueSubject<[Article], Never>([])
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    init(networkService: NetworkService, folder: Folder) {
        self.network = networkService
        self.folder = folder
    }
}

// MARK: - Custom Methods
extension LinkListViewModel {
    
    func getLinks() {
        network.request(FolderEndpoint.getArticlesInFolder(folderID: String(folder.id)))
            .tryMap { (data, _) -> [Article] in
                let decoder = JSONDecoder()
                let links = try decoder.decode([Article].self, from: data, keyPath: "articleList")
                return links
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] links in
                self?.linksSubject.send(links)
            }
            .store(in: &cancellables)
    }
    
    func deleteFolder(completion: @escaping () -> Void) {
        network.request(FolderEndpoint.deleteFolder(id: folder.id))
            .tryMap { (_, response) in
                let httpResponse = response as? HTTPURLResponse
                return httpResponse!.statusCode
            }
            .replaceError(with: 500)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statusCode in
                switch statusCode {
                case 204:
                    completion()
                default:
                    return
                }
            }
            .store(in: &cancellables)
        
    }
}
