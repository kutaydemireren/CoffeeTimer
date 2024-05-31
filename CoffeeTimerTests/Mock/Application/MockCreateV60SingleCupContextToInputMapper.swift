//
//  MockCreateContextToInputMapper.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 06/05/2023.
//

import Foundation
@testable import CoffeeTimer

class MockCreateContextToInputMapper: CreateContextToInputMapper {
    
    var _input: CreateV60RecipeInput!
    var _error: Error!
    
    func map(context: CreateRecipeContext) throws -> CreateV60RecipeInput {
        if let _error {
            throw _error
        }
        
        return _input
    }
}
