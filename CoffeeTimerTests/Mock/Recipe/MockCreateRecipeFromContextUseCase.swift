//
//  MockCreateRecipeFromContextUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import Foundation
@testable import CoffeeTimer

final class MockCreateRecipeFromContextUseCase: CreateRecipeFromContextUseCase {
    var _canCreate: Bool = true
    var _canCreateError: CreateRecipeFromContextUseCaseError?
    var _recipe: Recipe?
    
    func canCreate(from context: CreateRecipeContext) throws -> Bool {
        if let error = _canCreateError {
            throw error
        }
        return _canCreate
    }
    
    func create(from context: CreateRecipeContext) async -> Recipe? {
        return _recipe
    }
}

