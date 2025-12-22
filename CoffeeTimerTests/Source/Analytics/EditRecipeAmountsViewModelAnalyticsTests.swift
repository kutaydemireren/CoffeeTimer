//
//  EditRecipeAmountsViewModelAnalyticsTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import XCTest
@testable import CoffeeTimer

@MainActor
final class EditRecipeAmountsViewModelAnalyticsTests: XCTestCase {
    var mockAnalyticsTracker: MockAnalyticsTracker!
    var mockConfigureContextFromRecipeUseCase: MockConfigureContextFromRecipeUseCase!
    var mockUpdateRecipeFromContextUseCase: MockUpdateRecipeFromContextUseCase!
    var sut: EditRecipeAmountsViewModel!
    
    override func setUpWithError() throws {
        mockAnalyticsTracker = MockAnalyticsTracker()
        mockConfigureContextFromRecipeUseCase = MockConfigureContextFromRecipeUseCase()
        mockUpdateRecipeFromContextUseCase = MockUpdateRecipeFromContextUseCase()
        
        sut = EditRecipeAmountsViewModel(
            configureContextFromRecipeUseCase: mockConfigureContextFromRecipeUseCase,
            updateRecipeFromContextUseCase: mockUpdateRecipeFromContextUseCase,
            analyticsTracker: mockAnalyticsTracker
        )
    }
    
    func test_configure_shouldTrackEditAmountsOpened() {
        let recipe = Recipe.stubSingleV60
        
        sut.configure(with: recipe)
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "edit_amounts_opened" }
        XCTAssertNotNil(event)
    }
    
    func test_saveChanges_shouldTrackEditAmountsSaved() async {
        sut.configure(with: Recipe.stubSingleV60)
        mockAnalyticsTracker.trackedEvents.removeAll()
        mockAnalyticsTracker.trackCallCount = 0
        
        await sut.saveChanges()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "edit_amounts_saved" }
        XCTAssertNotNil(event)
    }
    
    func test_trackCancel_shouldTrackEditAmountsCancelled() {
        sut.trackCancel()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        let event = mockAnalyticsTracker.trackedEvents.first { $0.name == "edit_amounts_cancelled" }
        XCTAssertNotNil(event)
    }
}

