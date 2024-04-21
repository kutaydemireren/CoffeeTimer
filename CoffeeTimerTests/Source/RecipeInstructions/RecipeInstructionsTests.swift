//
//  RecipeInstructionsTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 20/04/2024.
//

import XCTest
@testable import CoffeeTimer

/*
 At the moment, `Recipe` stands for certain, finalised set of actions. Not possible to generate
 `Recipe` will need to stand for repeatable techniques: e.g. V60 Recipe, V60 Iced Recipe.
 So that, they can be iterated with `Input`s.

 Iterating `Recipe.instructions` with an `Input` will yield `BrewQueue`.
 `BrewQueue`s will consist of finalised stages that are ready to be used, same as before.

 # (New) `Recipe`:

 Recipe(
   profile: RecipeProfile ## todo
   ingredientTypes: [IngredientType]
   instructions: RecipeInstructions
 )

 # Input:

 Input(
   ingredients: [Ingredient]
 )

 # BrewQueue

 Until new recipe creation is initially introduced, should try mapping to existing `BrewStage`.

 Although the purpose of BrewQueue remains still, the actions will need to be updated
   to be able to reflect new API response.

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

 - BrewQueue

 To adapt new `Recipe`s into `BrewQueue`:
 - Existing `Recipe.ingredients` will be mapped to `Input(ingredients:)` and `Recipe.ingredientTypes` in the new system.
 - Profile can be skipped initially. Hardcode to skip for now.

 .. TBD ..
 
 */

//

struct RecipeInstructions: Decodable {
    typealias Ingredient = String

    let ingredients: [RecipeInstructions.Ingredient]
    let steps: [RecipeInstructionStep]
}

struct RecipeInstructionStep: Decodable {
    private enum Action: String, Decodable {
        case unknown
        case put
        case message
        case pause
    }

    enum CodingKeys: CodingKey {
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

protocol InstructionAction: Decodable {
    var message: String? { get }

    func stage(for input: RecipeInstructionInput) -> BrewStage
}

//struct MessageInstructionAction: InstructionAction {
//    let message: String?
//}

struct InstructionAmount: Codable {
    let type: String?
    let factor: Double?
    let factorOf: String?
    let constant: Double?
}

struct PutInstructionAction: InstructionAction {

    let ingredient: String?
    let amount: InstructionAmount?
    let message: String?

    func stage(for input: RecipeInstructionInput) -> BrewStage {
        return BrewStage(
            action: .pourWater(
                IngredientAmount(
                    amount: UInt(calculate(amount: amount, input: input)),
                    type: .gram
                )
            ),
            requirement: .none,
            startMethod: .userInteractive,
            passMethod: .userInteractive
        )
    }

    private func calculate(amount: InstructionAmount?, input: RecipeInstructionInput) -> Double {
        guard let factor = amount?.factor, let factorOf = amount?.factorOf, let constant = amount?.constant else { return 0.0 }
        guard let valueFactorOf = input.ingredients[factorOf] else { return 0.0 }

        return factor * valueFactorOf + constant
    }
}

struct PauseInstructionAction: InstructionAction {
    struct Duration: Codable {
        let type: String?
        let length: Int?
    }

    let ingredient: String?
    let duration: Duration?
    let message: String?

    func stage(for input: RecipeInstructionInput) -> BrewStage {
        return BrewStage(
            action: .pause,
            requirement: .countdown(UInt(duration?.length ?? 0)),
            startMethod: .auto,
            passMethod: .auto
        )
    }
}

//

struct RecipeInstructionInput {
    let ingredients: [RecipeInstructions.Ingredient: Double]
}

struct RecipeEngine {
    func recipe(for input: RecipeInstructionInput, from instructions: RecipeInstructions) -> Recipe {

        let stages = instructions.steps.compactMap { recipeInstructionStep in
            recipeInstructionStep.instructionAction?.stage(for: input)
        }

        return Recipe(
            recipeProfile: .empty,
            ingredients: [],
            brewQueue: BrewQueue(stages: stages)
        )
    }
}

//

extension RecipeInstructions {
    static var empty: Self {
        return RecipeInstructions(ingredients: [], steps: [])
    }
}

//

final class RecipeEngineTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_recipeForInput_whenInstructionsAvailable_shouldCreateExpectedBrewQueue() throws {
        let expectedBrewQueue = BrewQueue(
            stages: [
                BrewStage(
                    action: .pourWater(IngredientAmount(amount: 50, type: .gram)),
                    requirement: .none,
                    startMethod: .userInteractive,
                    passMethod: .userInteractive
                ),
                BrewStage(
                    action: .pause,
                    requirement: .countdown(10),
                    startMethod: .auto,
                    passMethod: .auto
                )
            ]
        )

        let sut = RecipeEngine()

        let recipe = sut.recipe(for: .init(ingredients: ["water": 250, "coffee": 15]), from: loadTestRecipeInstructions()!)

        XCTAssertEqual(recipe.brewQueue, expectedBrewQueue)
    }
}

func loadTestRecipeInstructions() -> RecipeInstructions? {
    guard let bundleURL = Bundle(for: RecipeEngineTests.self).url(forResource: "test", withExtension: "json") else {
        debugPrint("Coffee recipe file not found in bundle")
        return nil
    }

    do {
        let data = try Data(contentsOf: bundleURL)
        let decoder = JSONDecoder()
        let recipe = try decoder.decode(RecipeInstructions.self, from: data)
        return recipe
    } catch {
        debugPrint("Error decoding coffee recipe: \(error)")
        return nil
    }
}
