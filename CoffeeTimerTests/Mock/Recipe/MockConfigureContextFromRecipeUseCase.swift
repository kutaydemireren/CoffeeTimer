//
//  MockConfigureContextFromRecipeUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import Foundation
@testable import CoffeeTimer

final class MockConfigureContextFromRecipeUseCase: ConfigureContextFromRecipeUseCase {
    var configureCalled = false
    
    func configure(context: CreateRecipeContext, from recipe: Recipe, with ratios: [CoffeeToWaterRatio]) {
        configureCalled = true
    }
}

