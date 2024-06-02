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
            .init(action: .putCoffee(.init(amount: 10, type: .gram)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Put all your 10 grams of coffee to brewer"),
            .init(action: .pourWater(.init(amount: 40, type: .millilitre)), requirement: .countdown(10), startMethod: .userInteractive, passMethod: .auto, message: "To bloom, pour 40 millilitres of water\nTotal: 40 millilitres of water"),
            .init(action: .pourWater(.init(amount: 40, type: .millilitre)), requirement: .none, startMethod: .auto, passMethod: .userInteractive, message: "To bloom, pour 40 millilitres of water\nTotal: 80 millilitres of water"),
            .init(action: .pause, requirement: .countdown(30), startMethod: .auto, passMethod: .auto, message: "Let it bloom for 30 seconds.")
        ])
    }
}
