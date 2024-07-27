//
//  RecipeInstructionAction.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

enum RecipeInstructionAction {
    case put(PutInstructionActionViewModel)
    case pause(PauseActionModel)
    case message(MessageActionModel)
}

struct MessageActionModel: Equatable {
    let requirement: InstructionRequirementItem = .none
    let startMethod: InstructionInteractionMethodItem = .userInteractive
    let skipMethod: InstructionInteractionMethodItem = .userInteractive
    let message: String
    let details: String
}

struct PauseActionModel: Equatable {
    let requirement: InstructionRequirementItem = .countdown
    let duration: Double
    let startMethod: InstructionInteractionMethodItem = .auto
    let skipMethod: InstructionInteractionMethodItem = .auto
    let message: String
    let details: String
}
