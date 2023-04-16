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
			.init(action: .finish, requirement: .none)
		])
	}

	static var stub: BrewQueue {
		return Recipe.stub.brewQueue
	}
}

// TODO: Move
extension Recipe {
	static var stub: Recipe {
		return CreateV60SingleCupRecipeUseCaseImp().create(inputs: .init(name: "My Recipe", coffee: .init(amount: 15, type: .gram), water: .init(amount: 250, type: .gram)))
	}
}
