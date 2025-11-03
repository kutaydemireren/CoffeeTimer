//
//  RecipeRepositoryImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import Foundation
import Combine

struct RecipeConstants {
    static let selectedRecipeKey = "selectedRecipe"
    static let savedRecipesKey = "savedRecipes"
}

final class RecipeRepositoryImp: RecipeRepository {
    static let shared: RecipeRepositoryImp = RecipeRepositoryImp()

    var recipesPublisher: AnyPublisher<[Recipe], Never> {
        return savedRecipes.eraseToAnyPublisher()
    }
    private var savedRecipes: CurrentValueSubject<[Recipe], Never> = .init([])

    private let selectedRecipeKey = RecipeConstants.selectedRecipeKey
    private let savedRecipesKey = RecipeConstants.savedRecipesKey

    private var storage: Storage
    private var mapper: RecipeMapper

    private var cancellables: [AnyCancellable] = []

    init(
        storage: Storage = StorageImp(userDefaults: .standard),
        mapper: RecipeMapper = RecipeMapperImp()
    ) {
        self.storage = storage
        self.mapper = mapper

        refreshSavedRecipes()
    }
}

// MARK: Selected Recipe
extension RecipeRepositoryImp {
    func getSelectedRecipe() -> Recipe? {
        guard let selectedRecipeDTO = storage.load(forKey: selectedRecipeKey) as RecipeDTO? else {
            return nil
        }

        guard let selectedRecipe = try? mapper.mapToRecipe(recipeDTO: selectedRecipeDTO) else {
            return nil
        }

        // Ensure in-memory saved list is up-to-date before matching
        refreshSavedRecipes()

        // Match selected recipe against saved recipes list to ensure consistency
        // This is critical for backwards compatibility: old recipes get new UUIDs when loaded,
        // so we need to match them to the recipes in the list (which have the same UUIDs)
        return savedRecipes.value.first { recipe in
            // Try ID matching first
            if let selectedId = selectedRecipeDTO.id,
               selectedId == recipe.id.uuidString {
                return true
            }

            // Fallback to recipeProfile matching for old recipes without IDs
            return selectedRecipe.recipeProfile == recipe.recipeProfile
        }
    }

    func update(selectedRecipe: Recipe) {
        let recipeDTO = mapper.mapToRecipeDTO(recipe: selectedRecipe)
        storage.save(recipeDTO, forKey: selectedRecipeKey)
    }
}

// MARK: Save(d) Recipe(s)
extension RecipeRepositoryImp {
    func save(_ recipe: Recipe) {
        var newRecipeDTOs = getSavedRecipeDTOs()
        newRecipeDTOs.append(mapper.mapToRecipeDTO(recipe: recipe))
        storage.save(newRecipeDTOs, forKey: savedRecipesKey)
        refreshSavedRecipes()
    }

    private func refreshSavedRecipes() {
        let recipeDTOs = getSavedRecipeDTOs()
        let savedRecipes  = recipeDTOs.compactMap { try? mapper.mapToRecipe(recipeDTO: $0) }
        self.savedRecipes.send(savedRecipes)
    }

    private func getSavedRecipeDTOs() -> [RecipeDTO] {
        if let recipeDTO = storage.load(forKey: savedRecipesKey) as [RecipeDTO]? {
            return recipeDTO
        }
        return []
    }
}

// MARK: Update Saved Recipe
extension RecipeRepositoryImp {
    func update(savedRecipe: Recipe) {
        var savedRecipeDTOs = getSavedRecipeDTOs()
        let updatedRecipeDTO = mapper.mapToRecipeDTO(recipe: savedRecipe)

        if let index = findRecipeIndex(in: savedRecipeDTOs, matching: updatedRecipeDTO) {
            savedRecipeDTOs[index] = updatedRecipeDTO
            storage.save(savedRecipeDTOs, forKey: savedRecipesKey)
            refreshSavedRecipes()
        }
    }

    private func findRecipeIndex(in savedDTOs: [RecipeDTO], matching targetDTO: RecipeDTO) -> Int? {
        return savedDTOs.firstIndex(where: { savedDTO in
            // Primary: Match by ID if both have IDs
            if let savedId = savedDTO.id, let targetId = targetDTO.id {
                return savedId == targetId
            }

            // Fallback: Match by recipeProfile (name + brewMethod ID) for backwards compatibility
            // This handles old recipes without IDs
            guard let savedProfile = savedDTO.recipeProfile,
                  let targetProfile = targetDTO.recipeProfile,
                  let savedName = savedProfile.name,
                  let targetName = targetProfile.name,
                  let savedBrewMethodId = savedProfile.brewMethod?.id,
                  let targetBrewMethodId = targetProfile.brewMethod?.id else {
                return false
            }

            return savedName == targetName && savedBrewMethodId == targetBrewMethodId
        })
    }
}

// MARK: Remove
extension RecipeRepositoryImp {
    func remove(recipe: Recipe) {
        var savedRecipeDTOs = getSavedRecipeDTOs()
        let recipeDTO = mapper.mapToRecipeDTO(recipe: recipe)

        if let index = findRecipeIndex(in: savedRecipeDTOs, matching: recipeDTO) {
            savedRecipeDTOs.remove(at: index)
            storage.save(savedRecipeDTOs, forKey: savedRecipesKey)
            refreshSavedRecipes()
        }
    }
}
