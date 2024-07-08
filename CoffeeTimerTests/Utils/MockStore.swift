//
//  MockStore.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 29/05/2023.
//

@testable import CoffeeTimer

struct MockStore {
    static var savedRecipes: [Recipe] {
        return (0..<3).map { index in
            return Recipe(
                recipeProfile: .init(
                    name: "My Recipe - \(index)",
                    cupsCount: 1,
                    ratio: .ratio16
                ),
                ingredients: [
                    .init(ingredientType: .coffee, amount: .init(amount: 2 * index, type: .gram)),
                    .init(ingredientType: .water, amount: .init(amount: 40 * index, type: .millilitre))
                ],
                brewQueue: .stubMini
            )
        }
    }

    static var savedRecipeDTOs: [RecipeDTO] {
        return (0..<3).map { index in
            return RecipeDTO(
                recipeProfile: .init(
                    name: "My Recipe - \(index)",
                    cupsCount: 1,
                    ratio: "1:16"
                ),
                ingredients: [
                    .init(ingredientType: .coffee, amount: .init(amount: 2 * index, type: .gram)),
                    .init(ingredientType: .water, amount: .init(amount: 40 * index, type: .millilitre))
                ],
                brewQueue: .stubMini
            )
        }
    }
}
