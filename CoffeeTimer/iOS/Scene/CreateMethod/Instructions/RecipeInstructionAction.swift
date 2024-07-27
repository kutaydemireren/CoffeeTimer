//
//  RecipeInstructionAction.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

enum RecipeInstructionAction {
    case put(PutActionModel)
    case pause(PauseActionModel)
    case message(MessageActionModel)
}

struct PutActionModel {
    let requirement: InstructionRequirementItem
    let duration: Double
    let startMethod: InstructionInteractionMethodItem
    let skipMethod: InstructionInteractionMethodItem
    let message: String
    let details: String
    let ingredient: IngredientTypeItem
    let amount: String // TODO: parse

    func updating(
        requirement: InstructionRequirementItem? = nil,
        duration: Double? = nil,
        startMethod: InstructionInteractionMethodItem? = nil,
        skipMethod: InstructionInteractionMethodItem? = nil,
        message: String? = nil,
        details: String? = nil,
        ingredient: IngredientTypeItem? = nil,
        amount: String? = nil // TODO: parse
    ) -> Self {
        .init(
            requirement: requirement ?? self.requirement,
            duration: duration ?? self.duration,
            startMethod: startMethod ?? self.startMethod,
            skipMethod: skipMethod ?? self.skipMethod,
            message: message ?? self.message,
            details: details ?? self.details,
            ingredient: ingredient ?? self.ingredient,
            amount: amount ?? self.amount
        )
    }
}

struct MessageActionModel {
    let requirement: InstructionRequirementItem = .none
    let startMethod: InstructionInteractionMethodItem = .userInteractive
    let skipMethod: InstructionInteractionMethodItem = .userInteractive
    let message: String
    let details: String
}

struct PauseActionModel {
    let requirement: InstructionRequirementItem = .countdown
    let duration: Double
    let startMethod: InstructionInteractionMethodItem = .auto
    let skipMethod: InstructionInteractionMethodItem = .auto
    let message: String
    let details: String
}
