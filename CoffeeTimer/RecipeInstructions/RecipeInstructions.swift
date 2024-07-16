//
//  RecipeInstructions.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 21/04/2024.
//

import Foundation

/*
 At the moment, `Recipe` stands for certain, finalised set of actions. Not possible to generate
 `Recipe` will need to stand for repeatable techniques: e.g. V60 Recipe, V60 Iced Recipe.
 So that, they can be iterated with `Input`s.

 Iterating `Recipe.instructions` with an `Input` will yield `BrewQueue`.
 `BrewQueue`s will consist of finalised stages that are ready to be used, same as before.

 # (New) `Recipe`:

 Recipe(
 profile: RecipeProfile
 ingredientTypes: [IngredientType]
 instructions: RecipeInstructions
 )

 # New `RecipeProfile`:
 Recipe(
 name: String
 icon: ..Icon
 preferredRatio:

 # Input:

 Input(
 ingredients: [Ingredient]
 )

 # BrewQueue

 Until new recipe creation is initially introduced, should try mapping to existing `BrewStage`.

 At the moment, a `BrewQueue` is created when creating a `Recipe`. In the new system, a `BrewQueue` will be created whenever user decides to start the queue.

 In the new system, the main change in `BrewQueue` scene is that the `BrewQueue` model is separated from the `Recipe` model.
 `Recipe`s will consist `instructions`, and still be saved to user defaults.
 At the same time, `cupsCount` and `ratio` will be saved within `RecipeProfile`, denoting preferred user options for the recipe.

 Later: It must be very convenient to user to able the update these two preferences.
 .. TBD ..

 */

/*

 # Scenes:

 - CreateRecipe:
 1. `BrewMethod` Selection
 2. Preferred `Ingredient`s Selection
 3. Profile Creation
 4. Tap 'Save' -> Create `Input` (of selections)
 5. Fetch `Recipe` using `BrewMethod`
 6. Save `Recipe`

 - SelectedRecipe:
 1. Displays selected ratio using constant `BrewStage`
 2. On tap, generate a `BrewQueue` to populate `BrewQueueView`

 - BrewQueue:
 Remains same for now. Displays `BrewStage`s respecting the order in the queue.

 To adapt new `Recipe`s into `BrewQueue`:
 - Existing `Recipe.ingredients` will be mapped to `Input(ingredients:)` and `Recipe.ingredientTypes` in the new system.

 - Update Preferences
 .. TBD ..

 */

//

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
    let type: IngredientAmountTypeDTO?
    let factor: Double?
    let factorOf: String?
    let constant: Double?
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

    private func calculate(amount: InstructionAmount?, input: RecipeInstructionInput, in context: InstructionActionContext) -> IngredientAmount { // TODO: throw?
        guard let factor = amount?.factor, let factorOf = amount?.factorOf, let constant = amount?.constant else { return .zeroGram }
        
        var valueFactorOf = input.ingredients[factorOf]
        if valueFactorOf == nil {
            valueFactorOf = Double(process(message: factorOf, with: context.toDict()))
        }
        guard let valueFactorOf else { return .zeroGram }

        return IngredientAmount(
            amount: UInt(factor * valueFactorOf + constant),
            type: amount?.type?.map() ?? .gram
        )
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
