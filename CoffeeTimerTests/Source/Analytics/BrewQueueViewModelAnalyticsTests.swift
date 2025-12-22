//
//  BrewQueueViewModelAnalyticsTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import XCTest
@testable import CoffeeTimer

final class BrewQueueViewModelAnalyticsTests: XCTestCase {
    var mockAnalyticsTracker: MockAnalyticsTracker!
    var mockRecipeRepository: MockRecipeRepository!
    var sut: BrewQueueViewModel!
    
    override func setUpWithError() throws {
        mockAnalyticsTracker = MockAnalyticsTracker()
        mockRecipeRepository = MockRecipeRepository()
        mockRecipeRepository.getSelectedRecipeReturnValue = .stubSingleV60
        
        sut = BrewQueueViewModel(
            recipeRepository: mockRecipeRepository,
            analyticsTracker: mockAnalyticsTracker
        )
    }
    
    func test_beginQueue_shouldTrackBrewStarted() {
        sut.primaryAction()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        XCTAssertEqual(mockAnalyticsTracker.trackedEvents.first?.name, "brew_started")
        XCTAssertEqual(mockAnalyticsTracker.trackedEvents.first?.parameters?["brew_method_type"] as? String, "built-in")
        XCTAssertNotNil(mockAnalyticsTracker.trackedEvents.first?.parameters?["stage_count"] as? Int)
    }
    
    func test_endAction_shouldTrackBrewCancelled() {
        // Start brew first
        sut.primaryAction()
        mockAnalyticsTracker.trackedEvents.removeAll()
        mockAnalyticsTracker.trackCallCount = 0
        
        // End brew
        sut.endAction()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        let cancelEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "brew_cancelled" }
        XCTAssertNotNil(cancelEvent)
    }
    
    func test_requestEdit_shouldTrackEditRecipeRequested() {
        sut.requestEdit()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        let editEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "edit_recipe_requested" }
        XCTAssertNotNil(editEvent)
    }
    
    func test_presentGiftView_shouldTrackGiftViewOpened() {
        sut.presentGiftView()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        let giftViewEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "gift_view_opened" }
        XCTAssertNotNil(giftViewEvent)
    }
    
    func test_confirmGiftCoffee_shouldTrackBuyMeACoffeeOpened() {
        sut.confirmGiftCoffee()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        let bmcEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "buy_me_a_coffee_opened" }
        XCTAssertNotNil(bmcEvent)
    }
    
    func test_confirmPostBrew_shouldTrackBuyMeACoffeeOpened() {
        sut.confirmPostBrew()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        let bmcEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "buy_me_a_coffee_opened" }
        XCTAssertNotNil(bmcEvent)
    }
}

