//
//  WalletViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/18.
//

import Foundation
import Combine

final class WalletViewModel: ObservableObject {
    
    // MARK: Properties
    let cardSubject = CurrentValueSubject<[Folder], Never>([])
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Custom Methods
extension WalletViewModel {
}
