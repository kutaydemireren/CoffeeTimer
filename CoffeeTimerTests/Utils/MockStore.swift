//
//  MockStore.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 29/05/2023.
//

@testable import CoffeeTimer

struct MockStore {
    static var recipeProfileIconDTOs: [RecipeProfileIconDTO] {
        let recipeProfileIcons = ProfileIconStorage.recipeProfileIcons
        return recipeProfileIcons.map { recipeProfileIcon in
            return RecipeProfileIconDTO(title: recipeProfileIcon.title, colorHex: recipeProfileIcon.color, imageName: recipeProfileIcon.imageName)
        }
    }

    static var savedRecipes: [Recipe] {
        let recipeProfileIcons = ProfileIconStorage.recipeProfileIcons
        return (0..<3).map { index in
            return Recipe(
                recipeProfile: .init(
                    name: "My Recipe - \(index)",
                    icon: recipeProfileIcons[Int(
                        index
                    )],
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
        let recipeProfileIconDTOs = recipeProfileIconDTOs
        return (0..<3).map { index in
            return RecipeDTO(
                recipeProfile: .init(
                    name: "My Recipe - \(index)",
                    icon: recipeProfileIconDTOs[Int(
                        index
                    )],
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
