//
//  EditRecipeAmountsViewModel.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation
import Combine

@MainActor
final class EditRecipeAmountsViewModel: ObservableObject {
    @Published var allRatios: [CoffeeToWaterRatio] = []
    @Published var context = CreateRecipeContext()

    private let recipeRepository: RecipeRepository
    private let createRecipeFromContextUseCase: CreateRecipeFromContextUseCase
    private var originalRecipeId: UUID?

    init(
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared,
        createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp()
    ) {
        self.recipeRepository = recipeRepository
        self.createRecipeFromContextUseCase = createRecipeFromContextUseCase
    }

    func configure(with recipe: Recipe) {
        originalRecipeId = recipe.id
        context.recipeProfile = recipe.recipeProfile
        context.selectedBrewMethod = recipe.recipeProfile.brewMethod
        allRatios = recipe.recipeProfile.brewMethod.ratios

        if let water = recipe.ingredients.first(where: { $0.ingredientType == .water })?.amount,
           let coffee = recipe.ingredients.first(where: { $0.ingredientType == .coffee })?.amount,
           coffee.amount > 0 {
            let ratioValue = Double(water.amount) / Double(coffee.amount)
            context.ratio = closestRatio(to: ratioValue, in: allRatios)
        } else {
            context.ratio = allRatios.first
        }

        if recipe.cupsCount > 0 && recipe.cupSize > 0 {
            context.cupsCount = recipe.cupsCount
            context.cupSize = recipe.cupSize
        } else {
            // Fallback for old recipes that don't have cupsCount/cupSize persisted
            let isIced = recipe.recipeProfile.brewMethod.isIcedBrew
            let water = Double(
                recipe.ingredients
                    .first(
                        where: { $0.ingredientType == .water
                        })?.amount.amount ?? 0
            )
            let iceAmount = Double(
                recipe.ingredients
                    .first(where: { $0.ingredientType == .ice })?.amount.amount ?? 0
            )
            let totalLiquid = isIced ? water + iceAmount : water

            context.cupsCount = Double(max(recipe.recipeProfile.brewMethod.cupsCount.minimum, 1))
            context.cupSize = totalLiquid / max(context.cupsCount, 1)
        }
    }

    func saveChanges() async {
        // Create recipe input manually to preserve original ID when editing
        guard let _ = context.ratio else { return }
        guard let selectedBrewMethod = context.selectedBrewMethod else { return }
        
        let createContextToInputMapper = CreateContextToInputMapperImp()
        guard let input = try? createContextToInputMapper.map(context: context) else { return }
        
        let inputWithId = CreateRecipeInput(
            recipeProfile: input.recipeProfile,
            coffee: input.coffee,
            water: input.water,
            ice: input.ice,
            cupsCount: input.cupsCount,
            cupSize: input.cupSize,
            id: originalRecipeId
        )
        
        guard let instructions = try? await FetchRecipeInstructionsUseCaseImp().fetch(brewMethod: selectedBrewMethod) else { return }
        
        let updatedRecipe = CreateRecipeFromInputUseCaseImp().create(from: inputWithId, instructions: instructions)
        recipeRepository.update(selectedRecipe: updatedRecipe)
        recipeRepository.updateSavedRecipe(updatedRecipe)
    }

    private func closestRatio(to value: Double, in ratios: [CoffeeToWaterRatio]) -> CoffeeToWaterRatio? {
        return ratios.min(by: { abs($0.value - value) < abs($1.value - value) })
    }
}
