//
//  ConfigureContextFromRecipeUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/10/2025.
//

import Foundation

protocol ConfigureContextFromRecipeUseCase {
    func configure(context: CreateRecipeContext, from recipe: Recipe, with ratios: [CoffeeToWaterRatio])
}

struct ConfigureContextFromRecipeUseCaseImp: ConfigureContextFromRecipeUseCase {
    func configure(context: CreateRecipeContext, from recipe: Recipe, with ratios: [CoffeeToWaterRatio]) {
        context.recipeProfile = recipe.recipeProfile
        context.selectedBrewMethod = recipe.recipeProfile.brewMethod
        
        // Calculate ratio from ingredients
        if let water = recipe.ingredients.first(where: { $0.ingredientType == .water })?.amount,
           let coffee = recipe.ingredients.first(where: { $0.ingredientType == .coffee })?.amount,
           coffee.amount > 0 {
            let ratioValue = Double(water.amount) / Double(coffee.amount)
            context.ratio = closestRatio(to: ratioValue, in: ratios)
        } else {
            context.ratio = ratios.first
        }
        
        if recipe.cupsCount > 0 && recipe.cupSize > 0 {
            context.cupsCount = recipe.cupsCount
            context.cupSize = recipe.cupSize
        } else {
            // Fallback for old recipes that don't have cupsCount/cupSize persisted
            let isIced = recipe.recipeProfile.brewMethod.isIcedBrew
            let waterMl = Double(
                recipe.ingredients
                    .first(where: { $0.ingredientType == .water })?.amount.amount ?? 0
            )
            let iceAmount = Double(
                recipe.ingredients
                    .first(where: { $0.ingredientType == .ice })?.amount.amount ?? 0
            )
            let totalLiquid = isIced ? waterMl + iceAmount : waterMl
            
            context.cupsCount = Double(max(recipe.recipeProfile.brewMethod.cupsCount.minimum, 1))
            context.cupSize = totalLiquid / max(context.cupsCount, 1)
        }
    }
    
    private func closestRatio(to value: Double, in ratios: [CoffeeToWaterRatio]) -> CoffeeToWaterRatio? {
        return ratios.min(by: { abs($0.value - value) < abs($1.value - value) })
    }
}
