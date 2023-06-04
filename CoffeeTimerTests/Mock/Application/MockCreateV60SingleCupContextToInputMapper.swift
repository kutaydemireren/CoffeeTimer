//
//  MockCreateV60ContextToInputMapper.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

class MockCreateV60ContextToInputMapper: CreateV60ContextToInputMapper {

	enum TestError: Error {
		case invalidInput
	}

	var _input: CreateV60RecipeInput!
	var _context: CreateRecipeContext?

	func map(context: CreateRecipeContext) throws -> CreateV60RecipeInput {
		self._context = context

		guard let _input = _input else {
			throw TestError.invalidInput
		}

		return _input
	}
}
