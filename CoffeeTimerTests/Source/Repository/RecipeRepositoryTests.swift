//
//  RecipeRepositoryTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 11/05/2023.
//

import XCTest
@testable import CoffeeTimer

final class RecipeRepositoryTests: XCTestCase {

	override func setUpWithError() throws {
	}

	func test_getSavedRecipes_shouldReturnExpectedRecipes() {
		let expectedRecipes = MockStore.savedRecipes
		RecipeRepositoryImp.savedRecipes = expectedRecipes
		let sut = RecipeRepositoryImp()
		
		let resultedRecipes = sut.getSavedRecipes()
		
		XCTAssertEqual(resultedRecipes, expectedRecipes)
	}
}
