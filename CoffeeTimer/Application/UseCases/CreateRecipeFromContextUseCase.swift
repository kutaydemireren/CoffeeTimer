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
	private let CreateV60ContextToInputMapper: CreateV60ContextToInputMapper

	init(
		createV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase = CreateV60SingleCupRecipeUseCaseImp(),
		CreateV60ContextToInputMapper: CreateV60ContextToInputMapper = CreateV60ContextToInputMapperImp()
	) {
		self.createV60SingleCupRecipeUseCase = createV60SingleCupRecipeUseCase
		self.CreateV60ContextToInputMapper = CreateV60ContextToInputMapper
	}

	func create(from context: CreateRecipeContext) -> Recipe? {
		guard let input = try? CreateV60ContextToInputMapper.map(context: context) else {
			return nil
		}

		return createV60SingleCupRecipeUseCase.create(input: input)
	}
}
