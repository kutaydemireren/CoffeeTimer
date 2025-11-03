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

    private let migrationRunner: MigrationRunner
    
    init(
        storage: Storage = StorageImp(userDefaults: .standard),
        mapper: RecipeMapper = RecipeMapperImp(),
        migrationRunner: MigrationRunner = MigrationRunnerImp()
    ) {
        self.storage = storage
        self.mapper = mapper
        self.migrationRunner = migrationRunner
        
        // Run migrations before accessing recipes
        try? migrationRunner.run(migrations: [RecipeMigration()])
        
        refreshSavedRecipes()
    }
}

// MARK: Selected Recipe
extension RecipeRepositoryImp {
    func getSelectedRecipe() -> Recipe? {
        guard let selectedRecipeDTO = storage.load(forKey: selectedRecipeKey) as RecipeDTO?,
              let selectedId = selectedRecipeDTO.id else {
            return nil
        }

        // Ensure in-memory saved list is up-to-date before matching
        refreshSavedRecipes()

        // Match by ID only - all recipes have IDs after migration
        return savedRecipes.value.first { $0.id.uuidString == selectedId }
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
        guard let targetId = targetDTO.id else {
            return nil
        }
        
        // Match by ID only - all recipes have IDs after migration
        return savedDTOs.firstIndex { $0.id == targetId }
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
