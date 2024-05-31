//
//  CreateRecipeFromContextUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation

enum CreateRecipeFromContextUseCaseError: Error {
	case missingBrewMethod
	case missingRecipeProfile
	case missingCupsCount
	case missingRatio
}

protocol CreateRecipeFromContextUseCase {
	func canCreate(from context: CreateRecipeContext) throws -> Bool
	func create(from context: CreateRecipeContext) -> Recipe?
}

struct CreateRecipeFromContextUseCaseImp: CreateRecipeFromContextUseCase {
	private let createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase
	private let createV60IcedRecipeUseCase: CreateV60IcedRecipeUseCase
    private let createV60ContextToInputMapper: CreateV60ContextToInputMapper
    private let fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase
    private let createRecipeFromInputUseCase: CreateRecipeFromInputUseCase

	init(
		createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase = CreateV60SingleCupRecipeUseCaseImp(),
		createV60IcedRecipeUseCase: CreateV60IcedRecipeUseCase = CreateV60IcedRecipeUseCaseImp(),
        createV60ContextToInputMapper: CreateV60ContextToInputMapper = CreateV60ContextToInputMapperImp(),
        fetchRecipeInstructionsUseCase: FetchRecipeInstructionsUseCase = FetchRecipeInstructionsUseCaseImp(),
        createRecipeFromInputUseCase: CreateRecipeFromInputUseCase = CreateRecipeFromInputUseCaseImp()
	) {
		self.createV60SingleCupRecipeUseCase = createV60SingleCupRecipeUseCase
		self.createV60IcedRecipeUseCase = createV60IcedRecipeUseCase
        self.createV60ContextToInputMapper = createV60ContextToInputMapper
        self.fetchRecipeInstructionsUseCase = fetchRecipeInstructionsUseCase
        self.createRecipeFromInputUseCase = createRecipeFromInputUseCase
	}

	func canCreate(from context: CreateRecipeContext) throws  -> Bool {
		guard context.selectedBrewMethod != nil else {
			throw CreateRecipeFromContextUseCaseError.missingBrewMethod
		}

		guard context.recipeProfile.hasContent else {
			throw CreateRecipeFromContextUseCaseError.missingRecipeProfile
		}

		guard context.cupsCount > 0 else {
			throw CreateRecipeFromContextUseCaseError.missingCupsCount
		}

		guard context.ratio != nil else {
			throw CreateRecipeFromContextUseCaseError.missingRatio
		}

		return true
	}

    func create(from context: CreateRecipeContext) -> Recipe? {
        guard let selectedBrewMethod = context.selectedBrewMethod else { return nil }
        guard let input = try? createV60ContextToInputMapper.map(context: context) else { return nil }
        guard let instructions = try? fetchRecipeInstructionsUseCase.fetch(brewMethod: selectedBrewMethod) else { return nil }

        let recipe = createRecipeFromInputUseCase.create(from: input, instructions: instructions)

        return recipe
    }

    /*
	func create(from context: CreateRecipeContext) -> Recipe? {
		guard let input = try? createV60ContextToInputMapper.map(context: context) else {
			return nil
		}

		switch context.selectedBrewMethod {
		case .v60:
			return createV60(input: input, context: context)
		case .v60Iced:
			return createV60IcedRecipeUseCase.create(input: input)
		case .chemex, .frenchPress, .melitta, .none:
			return nil
		}
	}

	private func createV60(input: CreateV60RecipeInput, context: CreateRecipeContext) -> Recipe? {
		if context.cupsCount == 1 {
			return createV60SingleCupRecipeUseCase.create(input: input)
		} else {
			return nil
		}
	}
     */

    private func createRecipe(input: CreateV60RecipeInput, instructions: RecipeInstructions) -> Recipe {
        return Recipe(
            recipeProfile: input.recipeProfile,
            ingredients: [
                .init(ingredientType: .coffee, amount: input.coffee),
                .init(ingredientType: .water, amount: input.water),
            ],
            brewQueue: getBrew(input: input, instructions: instructions)
        )
    }

    private func getBrew(input: CreateV60RecipeInput, instructions: RecipeInstructions) -> BrewQueue {
        let input = RecipeInstructionInput(
            ingredients: [
                "water": Double(input.water.amount),
                "coffee": Double(input.coffee.amount)
            ]
        )

        return RecipeEngine
            .brewQueue(for: input, from: instructions)
    }
}

// TODO: Move
protocol FetchRecipeInstructionsUseCase {
    func fetch(brewMethod: BrewMethod) throws -> RecipeInstructions
}

struct FetchRecipeInstructionsUseCaseImp: FetchRecipeInstructionsUseCase {
    func fetch(brewMethod: BrewMethod) throws -> RecipeInstructions {
        fatalError("missing implementation")
    }
}

//

protocol CreateRecipeFromInputUseCase {
    func create(from context: CreateV60RecipeInput, instructions: RecipeInstructions) -> Recipe
}

struct CreateRecipeFromInputUseCaseImp: CreateRecipeFromInputUseCase {
    func create(from context: CreateV60RecipeInput, instructions: RecipeInstructions) -> Recipe {
        fatalError("missing implementation")
    }
}
