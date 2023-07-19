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
    let cardSubject = CurrentValueSubject<[String], Never>(["기본", "폴더1", "폴더2", "폴더1", "폴더2", "폴더1", "폴더2", "폴더1", "폴더2", "폴더1", "폴더2"])
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Custom Methods
extension WalletViewModel {
}
