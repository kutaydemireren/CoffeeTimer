//
//  MockGetSavedRecipesUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import Foundation
import Combine
@testable import CoffeeTimer

final class MockGetSavedRecipesUseCase: GetSavedRecipesUseCase {
    var selectedRecipe: Recipe? {
        _selectedRecipe
    }
    
    var savedRecipes: AnyPublisher<[Recipe], Never> {
        _savedRecipes.eraseToAnyPublisher()
    }
    
    var _selectedRecipe: Recipe?
    var _savedRecipes = CurrentValueSubject<[Recipe], Never>([])
}

