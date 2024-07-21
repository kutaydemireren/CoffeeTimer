//
//  RecipeInstructionStepItemView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/07/2024.
//

import SwiftUI

// TODO: move
fileprivate extension RecipeInstructionStepItem {
    static var stubPutHalfCoffee: Self {
        return .init(
            recipeInstructionStep: RecipeInstructionStep(
                instructionAction: PutInstructionAction(
                    requirement: .none,
                    startMethod: .userInteractive,
                    skipMethod: .auto,
                    message: "put coffee main message",
                    details: "put coffee details",
                    ingredient: .coffee,
                    amount: InstructionAmount(
                        type: .millilitre,
                        mainFactor: .init(factor: 0.6, factorOf: "coffee"),
                        adjustmentFactor: .init(factor: -0.1, factorOf: "coffee")
                    )
                )
            )
        )
    }
}

//

struct RecipeInstructionStepItem: Identifiable {
    let id = UUID()
    let recipeInstructionStep: RecipeInstructionStep?
}

//

struct RecipeInstructionStepItemView: View {
    let item: RecipeInstructionStepItem

    var body: some View {
        Text("Hello, \(String(describing: item.recipeInstructionStep?.instructionAction?.message))!")
    }
}

#Preview {
    RecipeInstructionStepItemView(item: .stubPutHalfCoffee)
}

