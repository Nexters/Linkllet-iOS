//
//  LoginViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/08/31.
//

import Foundation
import Combine

final class LoginViewModel {
    
    // MARK: Properties
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    init(networkService: NetworkService) {
        self.network = networkService
    }
}
