//
//  AppDelegate.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/07.
//

import Combine
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var cancellables = Set<AnyCancellable>()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ReachabliltyManager.shared.isConnectedPublisher
            .sink { isConnected in
                guard isConnected else { return }
                if MemberInfoManager.default.deviceIdPublisher.value.isEmpty {
                    MemberInfoManager.default.registerMember()
                }
            }
            .store(in: &cancellables)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}


}

