//
//  CreateRecipeFromContextUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation

protocol CreateRecipeFromContextUseCase {
	func create(from context: CreateRecipeContext) -> Recipe
}

struct CreateRecipeFromContextUseCaseImp {

	private let createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase
	private let createV60SingleCupContextToInputsMapper: CreateV60SingleCupContextToInputsMapper

	init(
		createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase,
		createV60SingleCupContextToInputsMapper: CreateV60SingleCupContextToInputsMapper
	) {
		self.createV60SingleCupRecipeUseCase = createV60SingleCupRecipeUseCase
		self.createV60SingleCupContextToInputsMapper = createV60SingleCupContextToInputsMapper
	}

	func create(from context: CreateRecipeContext) -> Recipe {
		let inputs = createV60SingleCupContextToInputsMapper.map(context: context)
		return createV60SingleCupRecipeUseCase.create(inputs: inputs)
	}
}
