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
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    let decoder = JSONDecoder()
                    let message = try? decoder.decode(String.self, from: data, keyPath: "message")
                    throw NetworkError.invalidResponse(message: message ?? "")
                }
                return true
            }
            .catch { [weak self] error in
                self?.inputStatusSubject.send(.duplicateError)
                return Just(false)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                guard isSuccess else { return }
                self?.inputStatusSubject.send(.saved)
            }
            .store(in: &cancellables)
    }
}
