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
        fatalError("Coffee recipe file not found in bundle")
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
        return RecipeInstructions(identifier: "", ingredients: [], steps: [])
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
            instructionAction = nil // try? MessageInstructionAction(from: decoder)
        case .pause:
            instructionAction = try? PauseInstructionAction(from: decoder)
        case .unknown:
            instructionAction = nil
        }
    }

}

//

struct InstructionAmount: Decodable {
    let type: String?
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

//

protocol InstructionAction: Decodable {
    var requirement: InstructionRequirement? { get }
    var startMethod: InstructionInteractionMethod? { get }
    var skipMethod: InstructionInteractionMethod? { get }
    var message: String? { get }

    func action(for input: RecipeInstructionInput) -> BrewStageAction
}

extension InstructionAction {
    func stage(for input: RecipeInstructionInput) -> BrewStage {
        return BrewStage(
            action: action(for: input),
            requirement: map(requirement),
            startMethod: map(startMethod),
            passMethod: map(skipMethod),
            message: message ?? ""
        )
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

//struct MessageInstructionAction: InstructionAction {
//    let message: String?
//}

extension RecipeInstructions.Ingredient {
    static var water: Self { return "water" }
    static var coffee: Self { return "coffee" }
}

struct PutInstructionAction: InstructionAction {
    let requirement: InstructionRequirement?
    let startMethod: InstructionInteractionMethod?
    let skipMethod: InstructionInteractionMethod?
    let message: String?

    let ingredient: RecipeInstructions.Ingredient?
    let amount: InstructionAmount?

    func action(for input: RecipeInstructionInput) -> BrewStageAction {
        switch ingredient {
        case .some(.coffee): return .putCoffee(calculate(amount: amount, input: input))
        case .some(.water): return .pourWater(calculate(amount: amount, input: input))
        case .some, .none: return .pourWater(.zeroGram)
        }
    }

    private func calculate(amount: InstructionAmount?, input: RecipeInstructionInput) -> IngredientAmount {
        guard let factor = amount?.factor, let factorOf = amount?.factorOf, let constant = amount?.constant else { return .zeroGram }
        guard let valueFactorOf = input.ingredients[factorOf] else { return .zeroGram }

        return IngredientAmount(
            amount: UInt(factor * valueFactorOf + constant),
            type: .gram
        )
    }
}

extension IngredientAmount {
    static var zeroGram: Self {
        return IngredientAmount(
            amount: 0,
            type: .gram
        )
    }
}

struct PauseInstructionAction: InstructionAction {
    let requirement: InstructionRequirement?
    let startMethod: InstructionInteractionMethod?
    let skipMethod: InstructionInteractionMethod?
    let message: String?

    func action(for input: RecipeInstructionInput) -> BrewStageAction {
        return .pause
    }
}

//

struct RecipeInstructionInput {
    let ingredients: [RecipeInstructions.Ingredient: Double]
}