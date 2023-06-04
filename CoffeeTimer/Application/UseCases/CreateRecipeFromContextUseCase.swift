//
//  CreateRecipeFromContextUseCase.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation

protocol CreateRecipeFromContextUseCase {
	func create(from context: CreateRecipeContext) -> Recipe?
}

struct CreateRecipeFromContextUseCaseImp: CreateRecipeFromContextUseCase {
	private let createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase
	private let createV60SingleCupContextToInputsMapper: CreateV60SingleCupContextToInputsMapper

	init(
		createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase = CreateV60SingleCupRecipeUseCaseImp(),
		createV60SingleCupContextToInputsMapper: CreateV60SingleCupContextToInputsMapper = CreateV60SingleCupContextToInputsMapperImp()
	) {
		self.createV60SingleCupRecipeUseCase = createV60SingleCupRecipeUseCase
		self.createV60SingleCupContextToInputsMapper = createV60SingleCupContextToInputsMapper
	}

	func create(from context: CreateRecipeContext) -> Recipe? {
		guard let inputs = try? createV60SingleCupContextToInputsMapper.map(context: context) else {
			return nil
		}

		return createV60SingleCupRecipeUseCase.create(inputs: inputs)
	}
}
