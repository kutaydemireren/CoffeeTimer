//
//  RecipeInstructions.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/04/2024.
//

import Foundation

func loadV60SingleRecipeInstructions() -> RecipeInstructions { // TODO: remove once fetching is possible
    guard let bundleURL = Bundle.main.url(forResource: "instructions_v60_single", withExtension: "json") else {
        fatalError("Instructions file not found in bundle")
    }

    do {
        let data = try Data(contentsOf: bundleURL)
        let decoder = JSONDecoder()
        let recipe = try decoder.decode(RecipeInstructions.self, from: data)
        return recipe
    } catch {
        fatalError("Error decoding coffee recipe: \(error)")
    }
}

//

struct RecipeInstructions: Decodable {
    typealias Ingredient = String

    let identifier: String
    let ingredients: [RecipeInstructions.Ingredient]
    let steps: [RecipeInstructionStep]
}

extension RecipeInstructions { // TODO: Move to test target
    static var empty: Self {
        return RecipeInstructions(
            identifier: "",
            ingredients: [],
            steps: []
        )
    }
}

struct RecipeInstructionStep: Decodable {
    private enum Action: String, Decodable {
        case unknown
        case put
        case message
        case pause
    }

    private enum CodingKeys: String, CodingKey {
        case action
    }

    let instructionAction: InstructionAction?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let action = (try? container.decode(Action.self, forKey: .action)) ?? .unknown

        switch action {
        case .put:
            instructionAction = try? PutInstructionAction(from: decoder)
        case .message:
            instructionAction = try? MessageInstructionAction(from: decoder)
        case .pause:
            instructionAction = try? PauseInstructionAction(from: decoder)
        case .unknown:
            instructionAction = nil
        }
    }

}

//

struct InstructionAmount: Decodable {
    struct Factor: Decodable {
        let factor: Double?
        let factorOf: String?
    }

    let type: IngredientAmountTypeDTO?
    let mainFactor: Factor?
    let adjustmentFactor: Factor?

    enum CodingKeys: CodingKey {
        case type
        case factor
        case factorOf
        case adjustment
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decodeIfPresent(IngredientAmountTypeDTO.self, forKey: .type)

        let factor = try container.decodeIfPresent(Double.self, forKey: .factor)
        let factorOf = try container.decodeIfPresent(String.self, forKey: .factorOf)
        mainFactor = Factor(factor: factor, factorOf: factorOf)

        adjustmentFactor = try container.decodeIfPresent(Factor.self, forKey: .adjustment)
    }
}

enum InstructionRequirement: Decodable {
    private struct Duration: Decodable {
        let type: String?
        let length: Double?
    }

    case unknown
    case countdown(UInt)

    private enum CodingKeys: String, CodingKey {
        case type
        case duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let typeString = try container.decode(String.self, forKey: .type)
        guard typeString == "countdown" else {
            self = .unknown
            return
        }

        let duration = try container.decode(Duration.self, forKey: .duration)
        guard let durationLength = duration.length, durationLength > 0 else {
            self = .unknown
            return
        }

        self = .countdown(UInt(round(durationLength)))
    }
}

enum InstructionInteractionMethod: String, Decodable {
    case auto
    case userInteractive
}

// TODO: move
struct RecipeInstructionInput {
    let ingredients: [RecipeInstructions.Ingredient: Double]
}

//

extension IngredientAmount {
    static var zeroGram: Self {
        return IngredientAmount(
            amount: 0,
            type: .gram
        )
    }
}

//

protocol MessageProcessing {
}

extension MessageProcessing {
    func process(message: String, with replacements: [String: String]) -> String {
        var processedMessage = message
        for (key, value) in replacements {
            processedMessage = processedMessage.replacingOccurrences(of: key, with: value)
        }
        return processedMessage
    }
}

//

struct InstructionActionContext {
    struct Context {
        let amount: Double?
        let coffee: Double?
        let water: Double?
        let duration: Double?
    }

    let current: Context?
    let total: Context?

    init(current: Context?, total: Context?) {
        self.current = current
        self.total = total
    }

    init(totalCoffee: Double, totalWater: Double) {
        current = nil
        total = .init(amount: nil, coffee: totalCoffee, water: totalWater, duration: nil)
    }

    var remaining: Context? {
        guard let totalCoffee = total?.coffee, let totalWater = total?.water else { return nil }
        let remainingCoffee = totalCoffee - (current?.coffee ?? 0)
        let remainingWater = totalWater - (current?.water ?? 0)
        return Context(
            amount: nil,
            coffee: remainingCoffee,
            water: remainingWater,
            duration: nil
        )
    }

    func toDict() -> [String: String] {
        var dict = [String: String]()

        if let current {
            dict["#current.amount"] = String(current.amount)
            dict["#current.coffee"] = String(current.coffee)
            dict["#current.water"] = String(current.water)
            dict["#current.duration"] = String(current.duration)
        }

        if let total {
            dict["#total.coffee"] = String(total.coffee)
            dict["#total.water"] = String(total.water)
        }

        if let remaining {
            dict["#remaining.coffee"] = String(remaining.coffee)
            dict["#remaining.water"] = String(remaining.water)
        }

        return dict
    }
}

extension String {
    init?(_ doubleVal: Double?) {
        guard let doubleVal else { return nil }
        self.init(doubleVal)
    }
}

extension InstructionActionContext {
    func updating(current: Context?) -> InstructionActionContext {
        return InstructionActionContext(
            current: current ?? self.current,
            total: total
        )
    }
}

//

protocol InstructionAction: Decodable, MessageProcessing {
    var requirement: InstructionRequirement? { get }
    var startMethod: InstructionInteractionMethod? { get }
    var skipMethod: InstructionInteractionMethod? { get }
    var message: String? { get }
    var details: String? { get }

    func action(for input: RecipeInstructionInput, in context: inout InstructionActionContext) -> BrewStageAction
}

extension InstructionAction {
    func stage(for input: RecipeInstructionInput, in context: inout InstructionActionContext) -> BrewStage {
        return BrewStage(
            action: action(for: input, in: &context),
            requirement: map(requirement),
            startMethod: map(startMethod),
            passMethod: map(skipMethod),
            message: process(message: message ?? "", with: context.toDict()),
            details: process(details: details, with: context.toDict())
        )
    }

    private func process(details: String?, with contextDict: [String: String]) -> String? {
        guard let details else { return nil }
        return process(message: details, with: contextDict)
    }

    private func map(_ requirement: InstructionRequirement?) -> BrewStageRequirement {
        switch requirement {
        case .countdown(let duration):
            return .countdown(duration)
        case .unknown, .none:
            return .none
        }
    }

    private func map(_ interactionMethod: InstructionInteractionMethod?) -> BrewStageActionMethod {
        switch interactionMethod {
        case .auto:
            return .auto
        case .userInteractive:
            return .userInteractive
        case .none:
            return .userInteractive
        }
    }
}

//

extension RecipeInstructions.Ingredient {
    static var water: Self { return "water" }
    static var coffee: Self { return "coffee" }
    static var ice: Self { return "ice" }
}

struct PutInstructionAction: InstructionAction {
    let requirement: InstructionRequirement?
    let startMethod: InstructionInteractionMethod?
    let skipMethod: InstructionInteractionMethod?
    let message: String?
    let details: String?

    let ingredient: RecipeInstructions.Ingredient?
    let amount: InstructionAmount?

    func action(for input: RecipeInstructionInput, in context: inout InstructionActionContext) -> BrewStageAction {
        let ingredientAmount = calculate(amount: amount, input: input, in: context)

        let action: BrewStageAction
        switch ingredient {
        case .coffee:
            action = .putCoffee(ingredientAmount)
        case .water:
            action = .pourWater(ingredientAmount)
        case .ice:
            action = .putIce(ingredientAmount)
        case .some, .none:
            action = .pourWater(.zeroGram)
        }

        let contextAmount = Double(ingredientAmount.amount)
        context = context.updating(
            current: InstructionActionContext.Context(
                amount: contextAmount,
                coffee: (context.current?.coffee ?? 0) + (ingredient == .coffee ? contextAmount : 0),
                water: (context.current?.water ?? 0) + (ingredient == .water ? contextAmount : 0),
                duration: nil
            )
        )

        return action
    }

    private func calculate(amount: InstructionAmount?, input: RecipeInstructionInput, in context: InstructionActionContext) -> IngredientAmount {
        return IngredientAmount(
            amount: UInt(calculate(factor: amount?.mainFactor, input: input, in: context) + calculate(factor: amount?.adjustmentFactor, input: input, in: context)),
            type: amount?.type?.map() ?? .gram
        )
    }

    private func calculate(factor amountFactor: InstructionAmount.Factor?, input: RecipeInstructionInput, in context: InstructionActionContext) -> Double {
        guard let factor = amountFactor?.factor, let factorOf = amountFactor?.factorOf else { return 0 }

        var valueFactorOf = input.ingredients[factorOf]
        if valueFactorOf == nil {
            valueFactorOf = Double(process(message: factorOf, with: context.toDict()))
        }
        guard let valueFactorOf else { return 0 }

        return factor * valueFactorOf
    }
}

//

struct PauseInstructionAction: InstructionAction {
    let requirement: InstructionRequirement?
    let startMethod: InstructionInteractionMethod?
    let skipMethod: InstructionInteractionMethod?
    let message: String?
    let details: String?

    func action(for input: RecipeInstructionInput, in context: inout InstructionActionContext) -> BrewStageAction {
        if case .countdown(let duration) = requirement {
            context = context.updating(
                current: InstructionActionContext.Context(
                    amount: context.current?.amount ?? 0,
                    coffee: (context.current?.coffee ?? 0),
                    water: (context.current?.water ?? 0),
                    duration: Double(duration)
                )
            )
        }

        return .pause
    }
}

//

struct MessageInstructionAction: InstructionAction {
    let requirement: InstructionRequirement?
    let startMethod: InstructionInteractionMethod?
    let skipMethod: InstructionInteractionMethod?
    let message: String?
    let details: String?

    func action(for input: RecipeInstructionInput, in context: inout InstructionActionContext) -> BrewStageAction {
        return .message
    }
}
