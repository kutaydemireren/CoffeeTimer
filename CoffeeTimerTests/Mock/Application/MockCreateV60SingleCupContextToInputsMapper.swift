//
//  MockCreateV60SingleCupContextToInputsMapper.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

class MockCreateV60SingleCupContextToInputsMapper: CreateV60SingleCupContextToInputsMapper {
	var _inputs: CreateV60SingleCupRecipeInputs = .stubSingleV60
	var _context: CreateRecipeContext?

	func map(context: CreateRecipeContext) -> CreateV60SingleCupRecipeInputs {
		self._context = context

		return _inputs
	}
}
