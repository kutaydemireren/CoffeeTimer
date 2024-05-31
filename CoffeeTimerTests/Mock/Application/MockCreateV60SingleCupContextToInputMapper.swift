//
//  MockCreateV60ContextToInputMapper.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

class MockCreateV60ContextToInputMapper: CreateV60ContextToInputMapper {

    var _input: CreateV60RecipeInput!
	var _error: Error!

	func map(context: CreateRecipeContext) throws -> CreateV60RecipeInput {
		if let _error {
			throw _error
		}

		return _input
	}
}
