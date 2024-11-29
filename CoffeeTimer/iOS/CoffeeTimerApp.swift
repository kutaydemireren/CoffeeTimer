//
//  CoffeeTimerApp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 19/02/2023.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CoffeeTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppFlowView(viewModel: .init())
                .preferredColorScheme(.light)
        }
    }
}
