//
//  RecipeEngine.swift
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

func loadV60SingleRecipeInstructions() -> RecipeInstructions { // TODO: remove once fetching is possible
	guard let bundleURL = Bundle.main.url(forResource: "instructions_v60", withExtension: "json") else {
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

	let ingredients: [RecipeInstructions.Ingredient]
	let steps: [RecipeInstructionStep]
}

extension RecipeInstructions { // TODO: Move to test target
	static var empty: Self {
		return RecipeInstructions(ingredients: [], steps: [])
	}
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

//

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

struct RecipeEngine { // TODO: temp name, rename
	static func recipe(for input: RecipeInstructionInput, from instructions: RecipeInstructions) -> Recipe {

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
