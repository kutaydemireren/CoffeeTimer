//
//  CoffeeTimerApp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 19/02/2023.
//

import SwiftUI

@main
struct CoffeeTimerApp: App {
    var body: some Scene {
        WindowGroup {
			SingleStageTimerView(viewModel: .init(timeIntervalLeft: 10))
        }
    }
}
