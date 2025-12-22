//
//  CoffeeTimerApp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 19/02/2023.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    private let appInitializer: AppInitializer = AppInitializerImp()
    private let analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Run migrations before Firebase and other initialization
        appInitializer.initialize()
        
        FirebaseApp.configure()
        
        // Track app open after Firebase is configured
        analyticsTracker.track(event: AnalyticsEvent(name: "app_open"))
        
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
