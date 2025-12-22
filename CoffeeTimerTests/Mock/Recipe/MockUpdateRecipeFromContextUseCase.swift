//
//  MockUpdateRecipeFromContextUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import Foundation
@testable import CoffeeTimer

final class MockUpdateRecipeFromContextUseCase: UpdateRecipeFromContextUseCase {
    var _recipe: Recipe?
    var updateCalledWithRecipeId: UUID?
    
    func update(recipeId: UUID, from context: CreateRecipeContext) async -> Recipe? {
        updateCalledWithRecipeId = recipeId
        return _recipe
    }
}

