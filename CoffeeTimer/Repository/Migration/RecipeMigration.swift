//
//  RecipeMigration.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation

struct RecipeMigration: Migration {
    let version = 1
    
    private let savedRecipesKey = RecipeConstants.savedRecipesKey
    private let selectedRecipeKey = RecipeConstants.selectedRecipeKey
    
    func migrate(storage: Storage) throws {
        // Load saved recipes first
        var savedRecipeDTOs = storage.load(forKey: savedRecipesKey) as [RecipeDTO]? ?? []
        var needsUpdate = false
        
        // Migrate saved recipes
        for index in savedRecipeDTOs.indices {
            if savedRecipeDTOs[index].id == nil {
                let newId = UUID().uuidString
                savedRecipeDTOs[index] = RecipeDTO(
                    id: newId,
                    recipeProfile: savedRecipeDTOs[index].recipeProfile,
                    ingredients: savedRecipeDTOs[index].ingredients,
                    brewQueue: savedRecipeDTOs[index].brewQueue,
                    cupsCount: savedRecipeDTOs[index].cupsCount,
                    cupSize: savedRecipeDTOs[index].cupSize
                )
                needsUpdate = true
            }
        }
        
        // Migrate selected recipe - match it with saved recipes if possible
        if var selectedRecipeDTO = storage.load(forKey: selectedRecipeKey) as RecipeDTO?,
           selectedRecipeDTO.id == nil {
            // Try to find a matching saved recipe by content (excluding ID)
            var matchedId: String? = nil
            for savedDTO in savedRecipeDTOs {
                if recipesMatch(selectedRecipeDTO, savedDTO) {
                    matchedId = savedDTO.id
                    break
                }
            }
            
            // Use matched ID or generate new one
            let selectedId = matchedId ?? UUID().uuidString
            selectedRecipeDTO = RecipeDTO(
                id: selectedId,
                recipeProfile: selectedRecipeDTO.recipeProfile,
                ingredients: selectedRecipeDTO.ingredients,
                brewQueue: selectedRecipeDTO.brewQueue,
                cupsCount: selectedRecipeDTO.cupsCount,
                cupSize: selectedRecipeDTO.cupSize
            )
            storage.save(selectedRecipeDTO, forKey: selectedRecipeKey)
        }
        
        // Save updated saved recipes
        if needsUpdate {
            storage.save(savedRecipeDTOs, forKey: savedRecipesKey)
        }
    }
    
    /// Compares two recipes by their content (excluding ID)
    private func recipesMatch(_ recipe1: RecipeDTO, _ recipe2: RecipeDTO) -> Bool {
        return recipe1.recipeProfile == recipe2.recipeProfile &&
               recipe1.ingredients == recipe2.ingredients &&
               recipe1.brewQueue == recipe2.brewQueue &&
               recipe1.cupsCount == recipe2.cupsCount &&
               recipe1.cupSize == recipe2.cupSize
    }
}

