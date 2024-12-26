//
//  CreateRecipeContext.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/05/2023.
//

import Foundation

final class CreateRecipeContext: ObservableObject {
    var selectedBrewMethod: BrewMethod? { // TODO: temp - remove selectedBrewMethod (replace with `recipeProfile` instead)
        get {
            recipeProfile.brewMethod == .none ? nil : recipeProfile.brewMethod
        }
        set {
            recipeProfile = recipeProfile.updating(brewMethod: newValue ?? .none)
        }
    }
    @Published var recipeProfile: RecipeProfile = .empty
    @Published var cupsCount: Double = 0.0
    @Published var cupSize: Double = 250.0
    @Published var ratio: CoffeeToWaterRatio?
}
