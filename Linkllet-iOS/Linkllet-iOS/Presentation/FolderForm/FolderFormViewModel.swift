//
//  FolderFormViewModel.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/17.
//

import Foundation
import Combine

final class FolderFormViewModel: ObservableObject {
    
    // MARK: Properties
    let isInputError = CurrentValueSubject<Bool, Never>(false)
    let titleSubject = CurrentValueSubject<String, Never>("")
}

// MARK: - Custom Methods
extension FolderFormViewModel {
    
    func checkInput() {
        if titleSubject.value.count == 0 {
            isInputError.send(true)
            // TODO: 팝업 "폴더 제목을 입력해 주세요"
            return
        }
        
        // TODO: network 연결,  팝업 "폴더 제목이 중복됩니다"
        
        isInputError.send(false)
    }
}
