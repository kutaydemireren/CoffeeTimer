//
//  RecipeInstructionActionItem.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

struct RecipeInstructionActionItem: Identifiable, Equatable {
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

enum RecipeInstructionAction: Titled, Hashable, Identifiable, Equatable {
    var title: String {
        switch self {
        case .message:
            return "Message"
        case .pause:
            return "Pause"
        case .put:
            return "Put"
        }
    }

    var detailedTitle: String {
        switch self {
        case .message:
            return "Message"
        case .pause(let model):
            return "Pause \("\(model.duration)".dashIfEmpty)s"
        case .put(let model):
            return "Put \(model.ingredient.title)"
        }
    }

    var message: String {
        switch self {
        case .message(let model):
            return model.message
        case .pause(let model):
            return model.message
        case .put(let model):
            return model.message
        }
    }

    var id: Self { return self }

    case put(PutActionModel)
    case pause(PauseActionModel)
    case message(MessageActionModel)
}
