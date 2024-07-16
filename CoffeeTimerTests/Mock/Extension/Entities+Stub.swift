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
            cupsCount: 1,
            ratio: .ratio16
        )
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
            .init(action: .putCoffee(.init(amount: 10, type: .gram)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Put all your 10.0 grams of coffee to brewer", details: nil),
            .init(action: .message, requirement: .none, startMethod: .auto, passMethod: .userInteractive, message: "Wet filter on hot tap water", details: nil),
            .init(action: .pourWater(.init(amount: 40, type: .millilitre)), requirement: .countdown(10), startMethod: .userInteractive, passMethod: .auto, message: "To bloom, pour 40.0 millilitres of water\nTotal: 40.0 millilitres of water", details: nil),
            .init(action: .pause, requirement: .countdown(30), startMethod: .auto, passMethod: .auto, message: "Let it bloom for 30.0 seconds", details: nil),
            .init(action: .pourWater(.init(amount: 40, type: .millilitre)), requirement: .none, startMethod: .auto, passMethod: .userInteractive, message: "To bloom, pour 40.0 millilitres of water", details: "Total: 80.0 millilitres of water"),
            .init(action: .pourWater(.init(amount: 120, type: .millilitre)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Use all remaining 120.0 millilitres of water", details: nil)
        ])
    }

    static var stubMiniIced: BrewQueue {
        BrewQueue(stages: [
            .init(action: .putIce(.init(amount: 80, type: .gram)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Put 80.0 g of ice into the vessel", details: nil),
            .init(action: .putCoffee(.init(amount: 10, type: .gram)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Put all your 10.0 grams of coffee to brewer", details: nil),
            .init(action: .message, requirement: .none, startMethod: .auto, passMethod: .userInteractive, message: "Wet filter on hot tap water", details: nil),
            .init(action: .pourWater(.init(amount: 24, type: .millilitre)), requirement: .countdown(10), startMethod: .userInteractive, passMethod: .auto, message: "To bloom, pour 24.0 millilitres of water\nTotal: 24.0 millilitres of water", details: nil),
            .init(action: .pause, requirement: .countdown(30), startMethod: .auto, passMethod: .auto, message: "Let it bloom for 30.0 seconds", details: nil),
            .init(action: .pourWater(.init(amount: 24, type: .millilitre)), requirement: .none, startMethod: .auto, passMethod: .userInteractive, message: "To bloom, pour 24.0 millilitres of water", details: "Total: 48.0 millilitres of water"),
            .init(action: .pourWater(.init(amount: 72, type: .millilitre)), requirement: .none, startMethod: .userInteractive, passMethod: .userInteractive, message: "Use all remaining 72.0 millilitres of water", details: nil)
        ])
    }
}
