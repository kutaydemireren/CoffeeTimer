//
//  RecipeInstructionActionItem+Stub.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2024.
//

import Foundation
@testable import CoffeeTimer

extension RecipeInstructionActionItem {
    static var stubPutCoffee: Self {
        return createSTUB(ingredient: .coffee)
    }

    static var stubPutWater: Self {
        return createSTUB(ingredient: .water)
    }

    static var stubPutIce: Self {
        return createSTUB(ingredient: .ice)
    }

    static func createSTUB(ingredient: IngredientTypeItem) -> Self {
        return .init(
            action: .put(
                .init(
                    requirement: .countdown,
                    duration: 10,
                    startMethod: .userInteractive,
                    skipMethod: .userInteractive,
                    message: "msg",
                    details: "dtl",
                    ingredient: ingredient,
                    mainFactor: 1.0,
                    mainFactorOf: .stubTotalCoffe,
                    adjustmentFactor: 0,
                    adjustmentFactorOf: .stubTotalCoffe
                )
            )
        )
    }
}
