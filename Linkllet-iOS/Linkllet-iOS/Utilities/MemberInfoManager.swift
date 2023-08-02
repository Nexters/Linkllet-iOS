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

    static var deviceId: String { UIDevice.current.identifierForVendor?.uuidString ?? "" }
    // 앱 재설치하면 초기화 https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor

    static private let userDefaultsKey = "deviceId"

    private var cancellables = Set<AnyCancellable>()
    private let useCase: MemberInfoUsecase

    private(set) var deviceIdPublisher = CurrentValueSubject<String, Never>(UserDefaults.standard.string(forKey: MemberInfoManager.userDefaultsKey) ?? "")

    static let `default` = MemberInfoManager(useCase: RealMemberInfoUsecase(network: NetworkService()))

    init(useCase: MemberInfoUsecase) {
        self.useCase = useCase
    }

    func registerMember() {
        useCase.reigster()
            .retry(3)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                UserDefaults.standard.set(Self.deviceId, forKey: Self.userDefaultsKey)
                self?.deviceIdPublisher.send(Self.deviceId)
            }
            .store(in: &cancellables)
    }
}

struct RealMemberInfoUsecase: MemberInfoUsecase {

    private let network: NetworkProvider

    init(network: NetworkProvider) {
        self.network = network
    }

    func reigster() -> AnyPublisher<Bool, Never> {
        return network.request(MemberEndpoint.register)
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
    func reigster() -> AnyPublisher<Bool, Never>
}
