//
//  RecipeInstructionsRepositoryImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 01/06/2024.
//

import XCTest
@testable import CoffeeTimer

final class RecipeInstructionsRepositoryImpTests: XCTestCase {
    var sut: RecipeInstructionsRepositoryImp!

    override func setUp() {
        sut = RecipeInstructionsRepositoryImp()
    }

    override func tearDown() {
        sut = nil
    }
}
