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
