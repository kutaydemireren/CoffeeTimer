//
//  CreateMethodViewModelAnalyticsTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import XCTest
@testable import CoffeeTimer

final class CreateMethodViewModelAnalyticsTests: XCTestCase {
    var mockAnalyticsTracker: MockAnalyticsTracker!
    var mockCreateBrewMethodUseCase: MockCreateBrewMethodUseCase!
    var sut: CreateMethodViewModel!
    
    override func setUpWithError() throws {
        mockAnalyticsTracker = MockAnalyticsTracker()
        mockCreateBrewMethodUseCase = MockCreateBrewMethodUseCase()
        
        sut = CreateMethodViewModel(
            createBrewMethodUseCase: mockCreateBrewMethodUseCase,
            analyticsTracker: mockAnalyticsTracker
        )
    }
    
    func test_init_shouldTrackCreateMethodOpened() {
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        XCTAssertEqual(mockAnalyticsTracker.trackedEvents.first?.name, "create_method_opened")
    }
    
    func test_nextPage_whenValid_shouldTrackValidationPass() {
        let context = CreateBrewMethodContext()
        context.methodTitle = "Test Method"
        context.instructions = [.stubPutCoffee]
        
        mockCreateBrewMethodUseCase._canCreate = true
        sut.selectedPage = 2 // Set to last page so nextPage triggers validation
        
        sut.nextPage(in: context)
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 2) // create_method_opened + create_method_validated
        let openedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_method_opened" }
        let validatedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_method_validated" }
        XCTAssertNotNil(openedEvent)
        XCTAssertNotNil(validatedEvent)
        XCTAssertEqual(validatedEvent?.parameters?["result"] as? String, "pass")
    }
    
    func test_nextPage_whenInvalid_shouldTrackValidationFail() {
        let context = CreateBrewMethodContext()
        mockCreateBrewMethodUseCase._canCreate = false
        mockCreateBrewMethodUseCase._canCreateError = .missingMethodTitle
        sut.selectedPage = 2 // Set to last page so nextPage triggers validation
        
        sut.nextPage(in: context)
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 2) // create_method_opened + create_method_validated
        let openedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_method_opened" }
        let validatedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_method_validated" }
        XCTAssertNotNil(openedEvent)
        XCTAssertNotNil(validatedEvent)
        XCTAssertEqual(validatedEvent?.parameters?["result"] as? String, "fail")
        XCTAssertEqual(validatedEvent?.parameters?["missing_field"] as? String, "method_title")
    }
}

