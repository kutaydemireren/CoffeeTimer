//
//  MockFetchRecipeInstructionsUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 31/05/2024.
//

import Foundation
@testable import CoffeeTimer

final class MockFetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase {
    var _instructions: RecipeInstructions = .empty
    var _error: Error?

    func fetch(brewMethod: BrewMethod) throws -> RecipeInstructions {
        if let _error {
            throw _error
        }

        return _instructions
    }
}
