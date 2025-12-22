//
//  MockRemoveRecipeUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import Foundation
@testable import CoffeeTimer

final class MockRemoveRecipeUseCase: RemoveRecipeUseCase {
    var removeCalledWith: Recipe?
    
    func remove(recipe: Recipe) {
        removeCalledWith = recipe
    }
}

