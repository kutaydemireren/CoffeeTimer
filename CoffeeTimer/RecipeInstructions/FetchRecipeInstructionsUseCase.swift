//
//  FetchRecipeInstructionsUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 31/05/2024.
//

import Foundation

// TODO: move
enum InstructionKeyword: String {
    static var userAllowedKeywords: [Self] {
        return [
            .coffee, .currentCoffee, .totalCoffee, .remainingCoffee,
            .water, .currentWater, .totalWater, .remainingWater,
            .ice
        ]
    }

    case coffee, currentCoffee = "#current.coffee", totalCoffee = "#total.coffee", remainingCoffee = "#remaining.coffee"
    case water, currentWater = "#current.water", totalWater = "#total.water", remainingWater = "#remaining.water"
    case ice
    case currentAmount = "#current.amount"
    case currentDuration = "#current.duration"

    var keywordItem: KeywordItem? {
        switch self {
        case .coffee, .totalCoffee:
            return .init(keyword: "#total.coffee", title: "Total Coffee")
        case .currentCoffee:
            return .init(keyword: "#current.coffee", title: "Current Coffee")
        case .remainingCoffee:
            return .init(keyword: "#remaining.coffee", title: "Remaining Coffee")
        case .water, .totalWater:
            return .init(keyword: "#total.water", title: "Total Water")
        case .currentWater:
            return .init(keyword: "#current.water", title: "Current Water")
        case .remainingWater:
            return .init(keyword: "#remaining.water", title: "Remaining Water")
        case .ice:
            return .init(keyword: "ice", title: "Total Ice")
        case .currentAmount, .currentDuration:
            return nil
        }
    }

    var keyword: String {
        return rawValue
    }
}

protocol FetchRecipeInstructionsUseCase {
    func fetch(brewMethod: BrewMethod) async throws -> RecipeInstructions
    func fetchActions(brewMethod: BrewMethod) async throws -> [RecipeInstructionAction]
}

struct FetchRecipeInstructionsUseCaseImp: FetchRecipeInstructionsUseCase {
    var repository: RecipeInstructionsRepository

    init(repository: RecipeInstructionsRepository = RecipeInstructionsRepositoryImp()) {
        self.repository = repository
    }

    func fetch(brewMethod: BrewMethod) async throws -> RecipeInstructions {
        try await repository.fetchInstructions(for: brewMethod)
    }

    func fetchActions(brewMethod: BrewMethod) async throws -> [RecipeInstructionAction] {
        let recipeInstructions = try await fetch(brewMethod: brewMethod)

        return try recipeInstructions.steps.compactMap { step in
            if let messageInstruction = step.instructionAction as? MessageInstructionAction {
                return RecipeInstructionAction.message(.init(message: messageInstruction.message ?? "", details: messageInstruction.details ?? ""))
            }

            if let pauseInstruction = step.instructionAction as? PauseInstructionAction,
               case let .countdown(duration) = pauseInstruction.requirement {
                return RecipeInstructionAction.pause(.init(duration: Double(duration), message: pauseInstruction.message ?? "", details: pauseInstruction.details ?? ""))
            }

            if let putInstruction = step.instructionAction as? PutInstructionAction {
                return RecipeInstructionAction
                    .put(
                        .init(
                            requirement: mapInstructionRequirement(putInstruction.requirement),
                            duration: findDuration(putInstruction.requirement),
                            startMethod: mapInteractionMethod(putInstruction.startMethod),
                            skipMethod: mapInteractionMethod(putInstruction.skipMethod),
                            message: putInstruction.message ?? "",
                            details: putInstruction.details ?? "",
                            ingredient: try mapIngredientType(putInstruction.ingredient),
                            mainFactor: putInstruction.amount?.mainFactor?.factor ?? 0,
                            mainFactorOf: factorOf(putInstruction.amount?.mainFactor),
                            adjustmentFactor: putInstruction.amount?.adjustmentFactor?.factor ?? 0,
                            adjustmentFactorOf: factorOf(putInstruction.amount?.adjustmentFactor)
                        )
                    )
            }

            return nil
        }
    }

    private func factorOf(_ amountFactor: InstructionAmount.Factor?) -> KeywordItem {
        let keyword = InstructionKeyword(rawValue: amountFactor?.factorOf ?? "")
        return keyword?.keywordItem ?? .init(keyword: "#current.coffee", title: "Current Coffee")
    }

    private func mapInstructionRequirement(_ requirement: InstructionRequirement?) ->  InstructionRequirementItem {
        switch requirement {
        case .countdown(_):
            return .countdown
        case .unknown, .none:
            return .none
        }
    }
    
    private func findDuration(_ requirement: InstructionRequirement?) ->  Double {
        switch requirement {
        case .countdown(let duration):
            return Double(duration)
        case .unknown, .none:
            return 0
        }
    }
    
    private func mapInteractionMethod(_ method: InstructionInteractionMethod?) ->  InstructionInteractionMethodItem {
        switch method {
        case .auto:
            return .auto
        case .userInteractive, .none:
            return .userInteractive
        }
    }
    
    private func mapIngredientType(_ ingredient: RecipeInstructions.Ingredient?) throws -> IngredientTypeItem {
        return IngredientTypeItem(rawValue: ingredient ?? "")! // TODO: forced!
    }
}
