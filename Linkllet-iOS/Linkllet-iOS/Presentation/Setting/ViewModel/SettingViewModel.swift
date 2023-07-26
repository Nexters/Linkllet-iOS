//
//  SettingViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/26.
//

import Foundation

final class SettingViewModel: ObservableObject {
    
    // MARK: Properties
    let menus = [["알림 설정", "사용 방법", "서비스 의견 보내기"], ["링크 휴지통"], ["제작자 소개", "현재 버전"]]
    private let network: NetworkService
    
    // MARK: Life Cycle
    init(networkService: NetworkService) {
        self.network = networkService
    }
}

// TODO: 서비스 의견 남기기 네트워크 연결
