//
//  PauseActionModel.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 27/07/2024.
//

import Foundation

struct PauseActionModel: Hashable, Equatable {
    let requirement: InstructionRequirementItem = .countdown
    let duration: Double
    let startMethod: InstructionInteractionMethodItem = .auto
    let skipMethod: InstructionInteractionMethodItem = .auto
    let message: String
    let details: String
}

extension PauseActionModel: UpdatableInstructionActionMessage {
    func updating(message: String) -> RecipeInstructionAction {
        .pause(.init(duration: duration, message: message, details: details))
    }

    func updating(details: String) -> RecipeInstructionAction {
        .pause(.init(duration: duration, message: message, details: details))
    }
}

extension PauseActionModel: UpdatableInstructionActionDuration {
    func updating(duration: Double) -> RecipeInstructionAction {
        .pause(.init(duration: duration, message: message, details: details))
    }
}
