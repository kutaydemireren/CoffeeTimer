//
//  RecipesViewModelAnalyticsTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import XCTest
@testable import CoffeeTimer

final class RecipesViewModelAnalyticsTests: XCTestCase {
    var mockAnalyticsTracker: MockAnalyticsTracker!
    var mockGetSavedRecipesUseCase: MockGetSavedRecipesUseCase!
    var mockUpdateSelectedRecipeUseCase: MockUpdateSelectedRecipeUseCase!
    var mockRemoveRecipeUseCase: MockRemoveRecipeUseCase!
    var sut: RecipesViewModel!
    
    override func setUpWithError() throws {
        mockAnalyticsTracker = MockAnalyticsTracker()
        mockGetSavedRecipesUseCase = MockGetSavedRecipesUseCase()
        mockUpdateSelectedRecipeUseCase = MockUpdateSelectedRecipeUseCase()
        mockRemoveRecipeUseCase = MockRemoveRecipeUseCase()
        
        sut = RecipesViewModel(
            getSavedRecipesUseCase: mockGetSavedRecipesUseCase,
            updateSelectedRecipeUseCase: mockUpdateSelectedRecipeUseCase,
            removeRecipeUseCase: mockRemoveRecipeUseCase,
            analyticsTracker: mockAnalyticsTracker
        )
    }
    
    func test_init_shouldTrackRecipesOpened() {
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        XCTAssertEqual(mockAnalyticsTracker.trackedEvents.first?.name, "recipes_opened")
    }
    
    func test_select_shouldTrackRecipeSelected() {
        let recipe = Recipe.stubSingleV60
        mockGetSavedRecipesUseCase._savedRecipes.value = [recipe]
        
        sut.select(recipe: recipe)
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 2) // recipes_opened + recipe_selected
        let openedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "recipes_opened" }
        let selectEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "recipe_selected" }
        XCTAssertNotNil(openedEvent)
        XCTAssertNotNil(selectEvent)
        XCTAssertEqual(selectEvent?.parameters?["brew_method_type"] as? String, "built-in")
    }
    
    func test_remove_shouldTrackRecipeDeleted() {
        let recipe = Recipe.stubSingleV60
        sut.recipes = [recipe]
        
        sut.removeRecipes(at: IndexSet(integer: 0))
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 2) // recipes_opened + recipe_deleted
        let openedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "recipes_opened" }
        let deleteEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "recipe_deleted" }
        XCTAssertNotNil(openedEvent)
        XCTAssertNotNil(deleteEvent)
        XCTAssertEqual(deleteEvent?.parameters?["brew_method_type"] as? String, "built-in")
    }
    
    func test_create_shouldTrackRecipeCreateStarted() {
        sut.create()
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 2) // recipes_opened + recipe_create_started
        let openedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "recipes_opened" }
        let createEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "recipe_create_started" }
        XCTAssertNotNil(openedEvent)
        XCTAssertNotNil(createEvent)
    }
}

