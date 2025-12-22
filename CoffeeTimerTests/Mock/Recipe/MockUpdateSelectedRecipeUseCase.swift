//
//  MockUpdateSelectedRecipeUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import Foundation
@testable import CoffeeTimer

final class MockUpdateSelectedRecipeUseCase: UpdateSelectedRecipeUseCase {
    var updateCalledWith: Recipe?
    
    func update(selectedRecipe: Recipe) {
        updateCalledWith = selectedRecipe
    }
}

