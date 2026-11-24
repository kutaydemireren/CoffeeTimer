//
//  MethodDraftStoreImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class MethodDraftStoreImpTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var sut: MethodDraftStoreImp!

    override func setUp() {
        userDefaults = UserDefaults(suiteName: "MethodDraftStoreImpTests")
        userDefaults.removePersistentDomain(forName: "MethodDraftStoreImpTests")
        sut = MethodDraftStoreImp(storage: StorageImp(userDefaults: userDefaults))
    }

    func test_saveAndLoad_shouldKeepTheWholeDraftIncludingKeptSteps() {
        var draft = MethodDraftFactory().draft(editing: .oldCustom, instructions: loadOldEditorV60Instructions())
        draft.steps.append(MethodStep(kind: .pour, amount: .rest, time: .doneBy(105), then: .carryOn, customText: "Pour the rest", tip: "Slowly"))

        sut.save(draft)

        XCTAssertEqual(sut.load(), draft)
    }

    func test_clear_shouldRemoveTheDraft() {
        sut.save(.scratch())

        sut.clear()

        XCTAssertNil(sut.load())
    }
}
