//
//  MockCreateV60SingleCupRecipeUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

class MockCreateV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase {
	var _recipe: Recipe = .stubSingleV60
	var _inputs: CreateV60SingleCupRecipeInputs?

	func create(inputs: CreateV60SingleCupRecipeInputs) -> Recipe {
		self._inputs = inputs

		return _recipe
	}
}
