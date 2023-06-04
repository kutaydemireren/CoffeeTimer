//
//  MockCreateV60ContextToInputMapper.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

class MockCreateV60ContextToInputMapper: CreateV60ContextToInputMapper {
	var _input: CreateV60RecipeInput = .stubSingleV60
	var _context: CreateRecipeContext?

	func map(context: CreateRecipeContext) -> CreateV60RecipeInput {
		self._context = context

		return _input
	}
}
