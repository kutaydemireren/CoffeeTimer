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
}

protocol CreateRecipeFromContextUseCase {
	func canCreate(from context: CreateRecipeContext) throws -> Bool
	func create(from context: CreateRecipeContext) -> Recipe?
}

struct CreateRecipeFromContextUseCaseImp: CreateRecipeFromContextUseCase {
	private let createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase
	private let createV60IcedRecipeUseCase: CreateV60IcedRecipeUseCase
	private let createV60ContextToInputMapper: CreateV60ContextToInputMapper

	init(
		createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase = CreateV60SingleCupRecipeUseCaseImp(),
		createV60IcedRecipeUseCase: CreateV60IcedRecipeUseCase = CreateV60IcedRecipeUseCaseImp(),
		CreateV60ContextToInputMapper: CreateV60ContextToInputMapper = CreateV60ContextToInputMapperImp()
	) {
		self.createV60SingleCupRecipeUseCase = createV60SingleCupRecipeUseCase
		self.createV60IcedRecipeUseCase = createV60IcedRecipeUseCase
		self.createV60ContextToInputMapper = CreateV60ContextToInputMapper
	}

	func canCreate(from context: CreateRecipeContext) throws  -> Bool {

		guard context.selectedBrewMethod != nil else {
			throw CreateRecipeFromContextUseCaseError.missingBrewMethod
		}

		guard context.recipeProfile.hasContent else {
			throw CreateRecipeFromContextUseCaseError.missingRecipeProfile
		}

		return context.cupsCount > 0 &&
		context.ratio != nil
	}

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
}
