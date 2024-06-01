//
//  FetchRecipeInstructionsUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 01/06/2024.
//

import XCTest
@testable import CoffeeTimer

final class FetchRecipeInstructionsUseCaseImpTests: XCTestCase {
    var sut: FetchRecipeInstructionsUseCaseImp!

    override func setUp() {
        sut = FetchRecipeInstructionsUseCaseImp()
    }

    override func tearDown() {
        sut = nil
    }
}
