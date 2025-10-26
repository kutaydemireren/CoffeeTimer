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

    init(
        recipeRepository: RecipeRepository = RecipeRepositoryImp.shared,
        createRecipeFromContextUseCase: CreateRecipeFromContextUseCase = CreateRecipeFromContextUseCaseImp()
    ) {
        self.recipeRepository = recipeRepository
        self.createRecipeFromContextUseCase = createRecipeFromContextUseCase
    }

    func configure(with recipe: Recipe) {
        context.recipeProfile = recipe.recipeProfile
        context.selectedBrewMethod = recipe.recipeProfile.brewMethod
        allRatios = recipe.recipeProfile.brewMethod.ratios

        // Derive initial ratio from existing ingredients if possible
        if let water = recipe.ingredients.first(where: { $0.ingredientType == .water })?.amount,
           let coffee = recipe.ingredients.first(where: { $0.ingredientType == .coffee })?.amount,
           coffee.amount > 0 {
            let ratioValue = Double(water.amount) / Double(coffee.amount)
            context.ratio = closestRatio(to: ratioValue, in: allRatios)
        } else {
            context.ratio = allRatios.first
        }

        // Initialize cups and cup size to match current total water (approx.)
        let isIced = recipe.recipeProfile.brewMethod.isIcedBrew
        let waterMl = Double(
            recipe.ingredients
                .first(
                    where: { $0.ingredientType == .water
                    })?.amount.amount ?? 0
        )
        let iceAmount = Double(
            recipe.ingredients
                .first(where: { $0.ingredientType == .ice })?.amount.amount ?? 0
        )
        let totalLiquid = isIced ? waterMl + iceAmount : waterMl

        context.cupsCount = Double(max(recipe.recipeProfile.brewMethod.cupsCount.minimum, 1))
        context.cupSize = totalLiquid / max(context.cupsCount, 1)
    }

    func saveChanges() async {
        guard let _ = await createRecipeFromContextUseCase.create(from: context) else {
            return
        }

        if let updatedRecipe = await createRecipeFromContextUseCase.create(from: context) {
            recipeRepository.update(selectedRecipe: updatedRecipe)
        }
    }

    private func closestRatio(to value: Double, in ratios: [CoffeeToWaterRatio]) -> CoffeeToWaterRatio? {
        return ratios.min(by: { abs($0.value - value) < abs($1.value - value) })
    }
}
