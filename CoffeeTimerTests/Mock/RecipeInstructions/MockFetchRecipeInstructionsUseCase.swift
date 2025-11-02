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
    var _instructionActions: [RecipeInstructionAction] = []
    var _error: Error?

    func fetch(brewMethod: BrewMethod) async throws -> RecipeInstructions {
        if let _error {
            throw _error
        }

        return _instructions
    }
    
    func fetchActions(brewMethod: BrewMethod) async throws -> [RecipeInstructionAction] {
        if let _error {
            throw _error
        }

        return _instructionActions
    }
}
