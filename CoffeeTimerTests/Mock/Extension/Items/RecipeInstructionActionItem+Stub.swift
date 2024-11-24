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

extension RecipeInstructionStep {
    static var stubPut: Self {
        .init(
            action: .put,
            instructionAction: PutInstructionAction.stub
        )
    }

    static var stubPause: Self {
        .init(
            action: .pause,
            instructionAction: PauseInstructionAction.stub
        )
    }

    static var stubMessage: Self {
        .init(
            action: .message,
            instructionAction: MessageInstructionAction.stub
        )
    }
}

extension PutInstructionAction {
    static var stub: Self {
        .init(
            requirement: .none,
            startMethod: .userInteractive,
            skipMethod: .userInteractive,
            message: "put msg",
            details: "dtl",
            ingredient: .coffee,
            amount: .init(
                type: .gram,
                mainFactor: .init(factor: 0.2, factorOf: "#total.coffee"),
                adjustmentFactor: .init(factor: -0.1, factorOf: "#total.coffee")
            )
        )
    }
}

extension PauseInstructionAction {
    static var stub: Self {
        .init(
            requirement: .countdown(20),
            startMethod: .auto,
            skipMethod: .auto,
            message: "pause msg",
            details: "dtl"
        )
    }
}

extension MessageInstructionAction {
    static var stub: Self {
        .init(
            requirement: .none,
            startMethod: .userInteractive,
            skipMethod: .userInteractive,
            message: "message msg",
            details: "dtl"
        )
    }
}
