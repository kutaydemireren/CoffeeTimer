//
//  CreateBrewMethodContext.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2024.
//

import Foundation

final class CreateBrewMethodContext: ObservableObject {
    @Published var selectedMethod: BrewMethod?

    @Published var methodTitle: String = ""

    var cupsCount: CupsCount {
        CupsCount(
            minimum: cupsCountMin > 0 ? Int(cupsCountMin) : 1,
            maximum: cupsCountMax > cupsCountMin ? Int(cupsCountMax) : nil
        )
    }
    @Published var cupsCountMin: Double = 0
    @Published var cupsCountMax: Double = 0

    @Published var instructions: [RecipeInstructionActionItem] = []
}
