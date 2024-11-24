//
//  RecipeInstructionStepMapper.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2024.
//

import Foundation

protocol RecipeInstructionStepMapper {
    func map(_ instructionItems: RecipeInstructionActionItem) -> RecipeInstructionStep
}

struct RecipeInstructionStepMapperImp: RecipeInstructionStepMapper  {
    func map(_ instructionItems: RecipeInstructionActionItem) -> RecipeInstructionStep {
        switch instructionItems.action {
        case .put(let putActionModel):
            map(putActionModel)
        case .pause(let pauseActionModel):
            map(pauseActionModel)
        case .message(let messageActionModel):
            map(messageActionModel)
        }
    }

    private func map(_ putActionModel: PutActionModel) -> RecipeInstructionStep {
        return .init(
            action: .put,
            instructionAction: PutInstructionAction(
                requirement: map(requirement: putActionModel.requirement, duration: putActionModel.duration),
                startMethod: map(interactionMethod: putActionModel.startMethod),
                skipMethod: map(interactionMethod: putActionModel.skipMethod),
                message: putActionModel.message,
                details: putActionModel.details,
                ingredient: putActionModel.ingredient.rawValue,
                amount: map(amount: putActionModel)
            )

        )
    }

    private func map(_ pauseActionModel: PauseActionModel) -> RecipeInstructionStep {
        return .init(
            action: .pause,
            instructionAction: PauseInstructionAction(
                requirement: map(requirement: pauseActionModel.requirement, duration: pauseActionModel.duration),
                startMethod: map(interactionMethod: pauseActionModel.startMethod),
                skipMethod: map(interactionMethod: pauseActionModel.skipMethod),
                message: pauseActionModel.message,
                details: pauseActionModel.details
            )
        )
    }

    private func map(_ messageActionModel: MessageActionModel) -> RecipeInstructionStep {
        return .init(
            action: .message,
            instructionAction: MessageInstructionAction(
                requirement: map(requirement: messageActionModel.requirement, duration: 0),
                startMethod: map(interactionMethod: messageActionModel.startMethod),
                skipMethod: map(interactionMethod: messageActionModel.skipMethod),
                message: messageActionModel.message,
                details: messageActionModel.details
            )
        )
    }

    private func map(requirement: InstructionRequirementItem, duration: Double) -> InstructionRequirement {
        switch requirement {
        case .countdown:
            return .countdown(UInt(duration))
        case .none:
            return .unknown
        }
    }

    private func map(interactionMethod: InstructionInteractionMethodItem) -> InstructionInteractionMethod {
        switch interactionMethod {
        case .auto:
            return .auto
        case .userInteractive:
            return .userInteractive
        }
    }

    private func map(amount putActionModel: PutActionModel) -> InstructionAmount {
        return .init(
            type: putActionModel.ingredient.isLiquid ? .millilitre : .gram,
            mainFactor: .init(factor: putActionModel.mainFactor, factorOf: putActionModel.mainFactorOf.keyword),
            adjustmentFactor: .init(factor: putActionModel.adjustmentFactor, factorOf: putActionModel.adjustmentFactorOf.keyword)
        )
    }
}
