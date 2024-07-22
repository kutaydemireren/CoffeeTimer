//
//  RecipeInstructionAction.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import Foundation

enum RecipeInstructionAction {
    case put(PutInstructionActionViewModel)
    case pause(PauseInstructionActionViewModel)
    case message(MessageInstructionActionViewModel)

    var message: String {
        switch self {
        case .put(let model):
            return model.message
        case .pause(let model):
            return model.message
        case .message(let model):
            return model.message
        }
    }
}
