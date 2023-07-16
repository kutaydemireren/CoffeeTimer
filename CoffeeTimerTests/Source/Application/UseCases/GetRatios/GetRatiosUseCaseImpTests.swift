//
//  GetRatiosUseCaseImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 11/06/2023.
//

import XCTest
@testable import CoffeeTimer

final class GetRatiosUseCaseImpTests: XCTestCase {

	var sut: GetRatiosUseCaseImp!

    override func setUpWithError() throws {
		sut = GetRatiosUseCaseImp()
    }

    func test_ratios_whenBrewMethodNil_shouldReturnEmptyRatios() throws {

		let resultedRatios = sut.ratios(for: nil)

		XCTAssertEqual(resultedRatios, [])
    }

    func test_ratios_whenBrewMethodIced_shouldReturnRatiosFrom15To19() throws {

		let expectedRatios: [CoffeeToWaterRatio] = [.ratio15, .ratio16, .ratio17, .ratio18, .ratio19]

		let resultedRatios = sut.ratios(for: .v60Iced)

		XCTAssertEqual(resultedRatios, expectedRatios)
    }

    func test_ratios_whenBrewMethodHot_shouldReturnRatiosFrom16To20() throws {

		let expectedRatios: [CoffeeToWaterRatio] = [.ratio16, .ratio17, .ratio18, .ratio19, .ratio20]

		let resultedRatios = sut.ratios(for: .v60)

		XCTAssertEqual(resultedRatios, expectedRatios)
    }
}
