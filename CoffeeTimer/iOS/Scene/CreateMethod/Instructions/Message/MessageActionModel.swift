//
//  MessageActionModel.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 27/07/2024.
//

import Foundation

struct MessageActionModel: Hashable, Equatable {
    let requirement: InstructionRequirementItem = .none
    let startMethod: InstructionInteractionMethodItem = .userInteractive
    let skipMethod: InstructionInteractionMethodItem = .userInteractive
    let message: String
    let details: String
}

extension MessageActionModel: UpdatableInstructionActionMessage {
    func updating(message: String) -> RecipeInstructionAction {
        .message(.init(message: message, details: details))
    }

    func updating(details: String) -> RecipeInstructionAction {
        .message(.init(message: message, details: details))
    }
}
