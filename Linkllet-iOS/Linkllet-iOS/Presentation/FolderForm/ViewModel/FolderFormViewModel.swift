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

enum FormType {
    case create
    case edit
}

final class FolderFormViewModel {
    
    // MARK: Properties
    let folder: Folder
    let formType = CurrentValueSubject<FormType, Never>(.create)
    let inputStatusSubject = CurrentValueSubject<InputStatus, Never>(.normal)
    let titleSubject = CurrentValueSubject<String, Never>("")
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    init(networkService: NetworkService, formType: FormType,
         folder: Folder = Folder(id: -1, name: "", type: .personalized, size: 0)) {
        self.network = networkService
        self.formType.send(formType)
        self.folder = folder
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
    
    func editFolder() {
        if titleSubject.value == folder.name {
            inputStatusSubject.send(.saved)
            return
        }
        
        network.request(FolderEndpoint.editFolder(id: folder.id, name: titleSubject.value))
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 204 else {
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
