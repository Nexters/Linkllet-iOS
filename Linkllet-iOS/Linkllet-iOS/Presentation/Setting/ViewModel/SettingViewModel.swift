//
//  SettingViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/26.
//

import Foundation
import Combine

final class SettingViewModel {
    
    // MARK: Properties
//    let menus = [["알림 설정", "사용 방법", "서비스 의견 보내기"], ["링크 휴지통"], ["제작자 소개", "현재 버전"]]
    let menus = [["서비스 의견 보내기"]]
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    init(networkService: NetworkService) {
        self.network = networkService
    }
}

// MARK: - Network
extension SettingViewModel {
    
    func createFeedback(feedback: String) {
        network.request(MemberEndpoint.createFeedback(feedback: feedback))
            .tryMap { (_, response) in
                let httpResponse = response as? HTTPURLResponse
                return httpResponse!.statusCode
            }
            .replaceError(with: 500)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            }
            .store(in: &cancellables)
    }
}
