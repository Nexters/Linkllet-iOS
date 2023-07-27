//
//  ReachabliltyManager.swift
//  Linkllet-iOS
//
//  Created by dochoi on 2023/07/26.
//

import Foundation
import Network
import Combine

final class ReachabliltyManager {

    let monitor = NWPathMonitor()
    private(set) var isConnectedPublisher = CurrentValueSubject<Bool, Never>(false)

    static let shared = ReachabliltyManager()

    private init() {
        monitor.start(queue: DispatchQueue.global())
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnectedPublisher.send(path.status == .satisfied)
        }
    }
}
