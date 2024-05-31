//
//  CreateRecipeFromInputUseCaseImp.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 31/05/2024.
//

import XCTest
@testable import CoffeeTimer

final class CreateRecipeFromInputUseCaseImpTests: XCTestCase {
    var sut: CreateRecipeFromInputUseCaseImp!

    override func setUp() {
        sut = CreateRecipeFromInputUseCaseImp()
    }

    override func tearDown() {
        sut = nil
    }

    func test_create_shouldReturnExpectedRecipeProfile() {
        let resultedRecipe = sut.create(from: .stubSingleV60, instructions: .empty)

        XCTAssertEqual(resultedRecipe.recipeProfile, .stubSingleV60)
    }
}
