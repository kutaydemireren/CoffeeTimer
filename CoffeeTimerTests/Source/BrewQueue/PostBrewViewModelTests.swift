//
//  PostBrewViewModelTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 19/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class PostBrewViewModelTests: XCTestCase {
    func test_header_whenReadRepeatedly_shouldReturnSameCopy() {
        let sut = PostBrewViewModel()
        let first = sut.header

        for _ in 0..<20 {
            XCTAssertEqual(sut.header.title, first.title)
            XCTAssertEqual(sut.header.subtext, first.subtext)
        }
    }

    func test_ctaAndAnimation_whenReadRepeatedly_shouldReturnSameValue() {
        let sut = PostBrewViewModel()
        let cta = sut.cta
        let animation = sut.animation

        for _ in 0..<20 {
            XCTAssertEqual(sut.cta, cta)
            XCTAssertEqual(sut.animation, animation)
        }
    }
}
