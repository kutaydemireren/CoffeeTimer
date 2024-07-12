//
//  RecipeRepository.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import Foundation
import Combine

protocol RecipeRepository: AnyObject {
    var recipesPublisher: AnyPublisher<[Recipe], Never> { get }
    
    func getSelectedRecipe() -> Recipe?
    func save(_ recipe: Recipe)
    func update(selectedRecipe: Recipe)
    func remove(recipe: Recipe)
}
