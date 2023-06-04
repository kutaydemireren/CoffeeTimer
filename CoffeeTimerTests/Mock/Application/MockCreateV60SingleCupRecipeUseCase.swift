//
//  MockCreateV60SingleCupRecipeUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

class MockCreateV60SingleCupRecipeUseCase: CreateV60SingleCupRecipeUseCase {
	var _recipe: Recipe!
	var _input: CreateV60RecipeInput?

	func create(input: CreateV60RecipeInput) -> Recipe {
		self._input = input

		return _recipe
	}
}
