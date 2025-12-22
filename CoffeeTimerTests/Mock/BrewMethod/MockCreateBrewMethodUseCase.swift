//
//  MockCreateBrewMethodUseCase.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import Foundation
@testable import CoffeeTimer

final class MockCreateBrewMethodUseCase: CreateBrewMethodUseCase {
    var _canCreate: Bool = true
    var _canCreateError: CreateBrewMethodUseCaseError?
    var createCalled = false
    
    func canCreate(from context: CreateBrewMethodContext) throws -> Bool {
        if let error = _canCreateError {
            throw error
        }
        return _canCreate
    }
    
    func create(from context: CreateBrewMethodContext) async throws {
        createCalled = true
    }
}

