//
//  MockCreateRecipeFromInputUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 31/05/2024.
//

import Foundation
@testable import CoffeeTimer

final class MockCreateRecipeFromInputUseCase: CreateRecipeFromInputUseCase {
    var _recipe: Recipe!

    func create(from context: CreateRecipeInput, instructions: RecipeInstructions) -> Recipe {
        return _recipe
    }
}
