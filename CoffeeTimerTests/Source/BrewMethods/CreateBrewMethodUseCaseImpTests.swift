//
//  CreateBrewMethodUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2024.
//

import XCTest
@testable import CoffeeTimer

final class CreateBrewMethodUseCaseImpTests: XCTestCase {
    var sut: CreateBrewMethodUseCaseImp!

    override func setUpWithError() throws {
        sut = CreateBrewMethodUseCaseImp()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_init() throws {
        XCTAssertNotNil(sut)
    }
}
