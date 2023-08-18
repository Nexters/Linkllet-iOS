//
//  SearchViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/08/18.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    
    // MARK: Properties
    struct State {
        let inputSubject = CurrentValueSubject<String, Never>("")
        let linksSubject = CurrentValueSubject<[Article], Never>([])
    }
    
    struct Action {
        let showToast = PassthroughSubject<String, Never>()
        let hideEmptyLabel = PassthroughSubject<Bool, Never>()
    }
    
    let state = State()
    let action = Action()
    
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    init(networkService: NetworkService) {
        self.network = networkService
    }
}

// MARK: - Custom Methods
extension SearchViewModel {
    
    func getLinks() {
        if (state.inputSubject.value.count < 2) {
            action.showToast.send("2글자 이상 입력해주세요")
            return
        }
        
        network.request(FolderEndpoint.searchArticles(content: state.inputSubject.value))
            .tryMap { (data, _) -> [Article] in
                let decoder = JSONDecoder()
                let links = try decoder.decode([Article].self, from: data, keyPath: "articleList")
                return links
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] links in
                self?.state.linksSubject.send(links)
                self?.action.hideEmptyLabel.send(!links.isEmpty)
            }
            .store(in: &cancellables)
    }
}
