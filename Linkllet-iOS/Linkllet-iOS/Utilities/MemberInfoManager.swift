//
//  MemberInfoManager.swift
//  Linkllet-iOS
//
//  Created by dochoi on 2023/07/18.
//

import Combine
import Foundation
import UIKit

final class MemberInfoManager {

    static private let userDefaultsKey = "userIdentifier"

    private var cancellables = Set<AnyCancellable>()
    private let useCase: MemberInfoUsecase

    private(set) var userIdentifierPublisher = CurrentValueSubject<String, Never>(UserDefaults.standard.string(forKey: MemberInfoManager.userDefaultsKey) ?? "")

    static let `default` = MemberInfoManager(useCase: RealMemberInfoUsecase(network: NetworkService()))

    init(useCase: MemberInfoUsecase) {
        self.useCase = useCase
        UserDefaults.standard.set(UUID().uuidString, forKey: "uuid")
    }

    func registerMember(_ uuid: String) {
        useCase.register(uuid)
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                UserDefaults.standard.set(uuid, forKey: Self.userDefaultsKey)
                self?.userIdentifierPublisher.send(uuid)
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        UserDefaults.standard.set(nil, forKey: Self.userDefaultsKey)
        userIdentifierPublisher.send("")
    }
}

struct RealMemberInfoUsecase: MemberInfoUsecase {

    private let network: NetworkProvider

    init(network: NetworkProvider) {
        self.network = network
    }

    func register(_ uuid: String) -> AnyPublisher<Bool, Never> {
        return network.request(MemberEndpoint.register(userIdentifier: uuid))
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    let decoder = JSONDecoder()
                    let message = try? decoder.decode(String.self, from: data, keyPath: "message")
                    throw NetworkError.invalidResponse(message: message ?? "")
                }
                return true
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}

protocol MemberInfoUsecase {
    func register(_ uuid: String) -> AnyPublisher<Bool, Never>
}
