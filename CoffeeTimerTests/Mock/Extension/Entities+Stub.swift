//
//  Entities+Stub.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/04/2023.
//

@testable import CoffeeTimer

extension Recipe {
    static var stubMini: Recipe {
        return Recipe(
            recipeProfile: .stubMini,
            ingredients: .stubMini,
            brewQueue: .stubMini
        )
    }
}

extension RecipeProfile {
    static var stubMini: RecipeProfile {
        return RecipeProfile(
            name: "My Recipe Mini",
            icon: .stubMini,
            cupsCount: 1,
            ratio: .ratio15
        )
    }
}

extension RecipeProfileIcon {
    static var stubMini: RecipeProfileIcon {
        return RecipeProfileIcon(title: "rocket-mini", color: "#200020")
    }
}

extension Array where Element == Ingredient {
    static var stubMini: [Ingredient] {
        return [
            Ingredient(ingredientType: .coffee, amount: .init(amount: 10, type: .gram)),
            Ingredient(ingredientType: .water, amount: .init(amount: 200, type: .millilitre))
        ]
    }
}

extension BrewQueue {
    static var stubMini: BrewQueue {
        BrewQueue(stages: [
            .init(action: .wet, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive),
            .init(action: .boilWater(.init(amount: 10, type: .gram)), requirement: .countdown(3), startMethod: .auto, passMethod: .userInteractive),
            .init(action: .finish, requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive)
        ])
    }
}
