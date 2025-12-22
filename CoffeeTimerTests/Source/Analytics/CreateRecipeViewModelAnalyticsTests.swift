//
//  CreateRecipeViewModelAnalyticsTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren.
//

import XCTest
@testable import CoffeeTimer

@MainActor
final class CreateRecipeViewModelAnalyticsTests: XCTestCase {
    var mockAnalyticsTracker: MockAnalyticsTracker!
    var mockCreateRecipeFromContextUseCase: MockCreateRecipeFromContextUseCase!
    var mockRecipeRepository: MockRecipeRepository!
    var sut: CreateRecipeViewModel!
    
    override func setUpWithError() throws {
        mockAnalyticsTracker = MockAnalyticsTracker()
        mockCreateRecipeFromContextUseCase = MockCreateRecipeFromContextUseCase()
        mockRecipeRepository = MockRecipeRepository()
        
        sut = CreateRecipeViewModel(
            createRecipeFromContextUseCase: mockCreateRecipeFromContextUseCase,
            recipeRepository: mockRecipeRepository,
            analyticsTracker: mockAnalyticsTracker
        )
    }
    
    func test_init_shouldTrackCreateRecipeOpened() {
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 1)
        XCTAssertEqual(mockAnalyticsTracker.trackedEvents.first?.name, "create_recipe_opened")
    }
    
    func test_trackBrewMethodChosen_shouldTrackBrewMethodChosen() {
        sut.trackBrewMethodChosen(brewMethodType: "built-in", methodId: "v60-single")
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 2) // create_recipe_opened + brew_method_chosen
        let openedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_recipe_opened" }
        let chosenEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "brew_method_chosen" }
        XCTAssertNotNil(openedEvent)
        XCTAssertNotNil(chosenEvent)
        XCTAssertEqual(chosenEvent?.parameters?["brew_method_type"] as? String, "built-in")
        XCTAssertEqual(chosenEvent?.parameters?["method_id"] as? String, "v60-single")
    }
    
    func test_nextPage_whenValid_shouldTrackValidationPass() {
        let context = CreateRecipeContext()
        context.selectedBrewMethod = .v60Single
        context.recipeProfile = .stubMini
        context.cupsCount = 1
        context.ratio = .ratio16
        
        mockCreateRecipeFromContextUseCase._canCreate = true
        sut.selectedPage = 3 // Set to last page so nextPage triggers validation
        
        sut.nextPage(in: context)
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 2) // create_recipe_opened + create_recipe_validated
        let openedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_recipe_opened" }
        let validatedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_recipe_validated" }
        XCTAssertNotNil(openedEvent)
        XCTAssertNotNil(validatedEvent)
        XCTAssertEqual(validatedEvent?.parameters?["result"] as? String, "pass")
    }
    
    func test_nextPage_whenInvalid_shouldTrackValidationFail() {
        let context = CreateRecipeContext()
        mockCreateRecipeFromContextUseCase._canCreate = false
        mockCreateRecipeFromContextUseCase._canCreateError = .missingBrewMethod
        sut.selectedPage = 3 // Set to last page so nextPage triggers validation
        
        sut.nextPage(in: context)
        
        XCTAssertEqual(mockAnalyticsTracker.trackCallCount, 2) // create_recipe_opened + create_recipe_validated
        let openedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_recipe_opened" }
        let validatedEvent = mockAnalyticsTracker.trackedEvents.first { $0.name == "create_recipe_validated" }
        XCTAssertNotNil(openedEvent)
        XCTAssertNotNil(validatedEvent)
        XCTAssertEqual(validatedEvent?.parameters?["result"] as? String, "fail")
        XCTAssertEqual(validatedEvent?.parameters?["missing_field"] as? String, "brew_method")
    }
}

