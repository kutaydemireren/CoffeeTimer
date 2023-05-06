//
//  BrewQueue+Stub.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 04/04/2023.
//

import Foundation

extension BrewQueue {
	static var stubMini: BrewQueue {
		BrewQueue(stages: [
			.init(action: .wet, requirement: .none),
			.init(action: .boil(water: .init(amount: 10, type: .gram)), requirement: .countdown(3)),
			.init(action: .finish, requirement: .none)
		])
	}

	static var stubSingleV60: BrewQueue {
		return Recipe.stubSingleV60.brewQueue
	}
}

// TODO: Move
extension Recipe {
	static var stubSingleV60: Recipe {
		return CreateV60SingleCupRecipeUseCaseImp().create(inputs: .init(name: "My Recipe", coffee: .init(amount: 15, type: .gram), water: .init(amount: 250, type: .gram)))
	}
}

extension CreateV60SingleCupRecipeInputs {
	static var stub: CreateV60SingleCupRecipeInputs{
		return CreateV60SingleCupRecipeInputs(name: "name", coffee: .init(amount: 3, type: .gram), water: .init(amount: 10, type: .millilitre))
	}
}
