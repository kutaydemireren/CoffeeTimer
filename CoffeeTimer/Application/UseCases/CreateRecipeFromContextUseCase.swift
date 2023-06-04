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

	func create(from context: CreateRecipeContext) -> Recipe? {
		// TODO: Use `context` to separate iced from single cup
		guard let input = try? createV60ContextToInputMapper.map(context: context) else {
			return nil
		}

		return createV60IcedRecipeUseCase.create(input: input)
	}
}
