//
//  MockRecipeRepository.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation
import Combine
@testable import CoffeeTimer

final class MockRecipeRepository: RecipeRepository {
    var recipesPublisher: AnyPublisher<[Recipe], Never> {
        savedRecipes.eraseToAnyPublisher()
    }
    
    var savedRecipes = CurrentValueSubject<[Recipe], Never>([])
    
    var getSelectedRecipeReturnValue: Recipe?
    var updateSelectedRecipeCalledWith: Recipe?
    var updateSavedRecipeCalledWith: Recipe?
    var saveCalledWith: Recipe?
    var removeCalledWith: Recipe?
    
    func getSelectedRecipe() -> Recipe? {
        return getSelectedRecipeReturnValue
    }
    
    func save(_ recipe: Recipe) {
        saveCalledWith = recipe
    }
    
    func update(selectedRecipe: Recipe) {
        updateSelectedRecipeCalledWith = selectedRecipe
    }
    
    func update(savedRecipe: Recipe) {
        updateSavedRecipeCalledWith = savedRecipe
    }
    
    func remove(recipe: Recipe) {
        removeCalledWith = recipe
    }
}

