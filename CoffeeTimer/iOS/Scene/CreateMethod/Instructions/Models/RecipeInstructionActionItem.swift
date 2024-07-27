//
//  RecipeInstructionActionItem.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

struct RecipeInstructionActionItem: Identifiable {
    let id: UUID
    let action: RecipeInstructionAction

    init(id: UUID = UUID(), action: RecipeInstructionAction) {
        self.id = id
        self.action = action
    }
}

extension RecipeInstructionActionItem {
    func updating(action: RecipeInstructionAction) -> Self {
        return Self.init(id: id, action: action)
    }
}

enum RecipeInstructionAction {
    case put(PutActionModel)
    case pause(PauseActionModel)
    case message(MessageActionModel)
}
