//
//  FolderFormViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/17.
//

import Foundation
import Combine

enum InputStatus {
    case normal
    case emptyError
    case duplicateError
    case saved
}

enum ViewType {
    case save
    case patch
}

final class FolderFormViewModel: ObservableObject {
    
    // MARK: Properties
    let inputStatusSubject = CurrentValueSubject<InputStatus, Never>(.normal)
    let titleSubject = CurrentValueSubject<String, Never>("")
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    init(networkService: NetworkService) {
        self.network = networkService
    }
}

// MARK: - Custom Methods
extension FolderFormViewModel {
    
    func createFolder() {
        if titleSubject.value.count == 0 {
            inputStatusSubject.send(.emptyError)
            return
        }
        
        network.request(FolderEndpoint.createFolder(name: titleSubject.value))
            .tryMap { (_, response) in
                let httpResponse = response as? HTTPURLResponse
                return httpResponse!.statusCode
            }
            .replaceError(with: 500)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statusCode in
                switch statusCode {
                case 200:
                    self?.inputStatusSubject.send(.saved)
                case 400:
                    self?.inputStatusSubject.send(.duplicateError)
                default:
                    return
                }
            }
            .store(in: &cancellables)
    }
}
