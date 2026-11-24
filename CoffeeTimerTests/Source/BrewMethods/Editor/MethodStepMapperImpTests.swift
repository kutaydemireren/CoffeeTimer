//
//  MethodStepMapperImpTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class MethodStepMapperImpTests: XCTestCase {
    private let dose = ReferenceDose(coffee: 30, water: 500, ice: 200)
    private var sut: MethodStepMapperImp!

    override func setUp() {
        sut = MethodStepMapperImp()
    }

    private func amount(of step: RecipeInstructionStep) -> InstructionAmount? {
        (step.instructionAction as? PutInstructionAction)?.amount
    }

    // MARK: Grams → factors

    func test_instructionStep_whenUpToATotal_shouldStoreShareOfWaterMinusCurrentWater() {
        let step = MethodStep(kind: .pour, amount: .upTo(300))

        let result = sut.instructionStep(for: step, dose: dose, duration: nil)

        XCTAssertEqual(result.action, .put)
        XCTAssertEqual(amount(of: result)?.mainFactor, .init(factor: 0.6, factorOf: "water"))
        XCTAssertEqual(amount(of: result)?.adjustmentFactor, .init(factor: -1, factorOf: "#current.water"))
        XCTAssertEqual(amount(of: result)?.type, .millilitre)
    }

    func test_instructionStep_whenAddAnAmount_shouldStoreShareOfWater() {
        let step = MethodStep(kind: .pour, amount: .add(50))

        let result = sut.instructionStep(for: step, dose: dose, duration: nil)

        XCTAssertEqual(amount(of: result)?.mainFactor, .init(factor: 0.1, factorOf: "water"))
        XCTAssertNil(amount(of: result)?.adjustmentFactor)
    }

    func test_instructionStep_whenTheRest_shouldStoreAllRemainingWater() {
        let step = MethodStep(kind: .pour, amount: .rest)

        let result = sut.instructionStep(for: step, dose: dose, duration: nil)

        XCTAssertEqual(amount(of: result)?.mainFactor, .init(factor: 1, factorOf: "#remaining.water"))
        XCTAssertNil(amount(of: result)?.adjustmentFactor)
    }

    func test_instructionStep_whenAddCoffeeAndIce_shouldStoreShareOfTheirOwnTotals() {
        let coffee = sut.instructionStep(for: MethodStep(kind: .addCoffee, amount: .add(30)), dose: dose, duration: nil)
        let ice = sut.instructionStep(for: MethodStep(kind: .addIce, amount: .add(100)), dose: dose, duration: nil)

        XCTAssertEqual(amount(of: coffee)?.mainFactor, .init(factor: 1, factorOf: "coffee"))
        XCTAssertEqual(amount(of: coffee)?.type, .gram)
        XCTAssertEqual((coffee.instructionAction as? PutInstructionAction)?.ingredient, "coffee")
        XCTAssertEqual(amount(of: ice)?.mainFactor, .init(factor: 0.5, factorOf: "ice"))
        XCTAssertEqual((ice.instructionAction as? PutInstructionAction)?.ingredient, "ice")
    }

    func test_instructionStep_shouldStoreKindAndDoneByAndCountdown() {
        let step = MethodStep(kind: .pour, amount: .upTo(300), time: .doneBy(75), then: .carryOn)

        let result = sut.instructionStep(for: step, dose: dose, duration: 30)

        XCTAssertEqual(result.kind, "pour")
        XCTAssertEqual(result.doneBy, 75)
        XCTAssertEqual(result.instructionAction?.requirement, .countdown(30))
        XCTAssertEqual(result.instructionAction?.startMethod, .auto)
        XCTAssertEqual(result.instructionAction?.skipMethod, .auto)
    }

    func test_instructionStep_whenNoTimer_shouldWaitForTap() {
        let step = MethodStep(kind: .pour, amount: .add(50), then: .carryOn)

        let result = sut.instructionStep(for: step, dose: dose, duration: nil)

        XCTAssertNil(result.instructionAction?.requirement)
        XCTAssertEqual(result.instructionAction?.skipMethod, .userInteractive)
    }

    func test_instructionStep_whenWait_shouldStorePause() {
        let result = sut.instructionStep(for: MethodStep(kind: .wait, time: .takes(45)), dose: dose, duration: 45)

        XCTAssertEqual(result.action, .pause)
        XCTAssertTrue(result.instructionAction is PauseInstructionAction)
        XCTAssertEqual(result.instructionAction?.message, "Wait 45 s")
    }

    func test_instructionStep_whenSwirlOrNote_shouldStoreMessage() {
        let swirl = sut.instructionStep(for: MethodStep(kind: .swirl), dose: dose, duration: nil)
        let note = sut.instructionStep(for: MethodStep(kind: .note, customText: "Rinse the filter"), dose: dose, duration: nil)

        XCTAssertEqual(swirl.action, .message)
        XCTAssertEqual(swirl.kind, "swirl")
        XCTAssertEqual(note.instructionAction?.message, "Rinse the filter")
    }

    func test_instructionStep_whenTipEmpty_shouldStoreNoDetails() {
        let result = sut.instructionStep(for: MethodStep(kind: .swirl, tip: "  "), dose: dose, duration: nil)

        XCTAssertNil(result.instructionAction?.details)
    }

    // MARK: Factors → grams

    func test_roundTrip_eachAmountKind_shouldGiveBackTheSameGrams() {
        let steps = [
            MethodStep(kind: .pour, amount: .upTo(300)),
            MethodStep(kind: .pour, amount: .add(60)),
            MethodStep(kind: .pour, amount: .rest),
            MethodStep(kind: .addCoffee, amount: .add(30)),
            MethodStep(kind: .addIce, amount: .add(100))
        ]

        for step in steps {
            let stored = sut.instructionStep(for: step, dose: dose, duration: nil)
            let result = sut.methodStep(from: stored, dose: dose)
            XCTAssertEqual(result.kind, step.kind)
            XCTAssertEqual(result.amount?.mode, step.amount?.mode)
            XCTAssertEqual(result.amount?.grams ?? -1, step.amount?.grams ?? -1, accuracy: 0.0001)
            XCTAssertNil(result.legacy)
            XCTAssertNil(result.customText, "generated text should be recognised as generated")
        }
    }

    func test_storedSteps_atTheReferenceDose_shouldBrewTheTypedGrams() {
        let draft = MethodDraft(
            name: "V60", iconName: "", coffee: 30, water: 500, ice: nil,
            steps: [
                MethodStep(kind: .addCoffee, amount: .add(30)),
                MethodStep(kind: .pour, amount: .add(60)),
                MethodStep(kind: .pour, amount: .upTo(300)),
                MethodStep(kind: .pour, amount: .rest)
            ],
            origin: .scratch
        )

        let preview = MethodDraftCompiler().preview(for: draft)

        XCTAssertEqual(preview.steps.map(\.addedGrams), [30, 60, 240, 200])
        XCTAssertEqual(preview.steps.map(\.waterTotal), [0, 60, 300, 500])
        XCTAssertEqual(preview.steps.map(\.text), ["Add 30 g of coffee", "Pour 60 g", "Pour up to 300 g", "Pour the rest, 200 g"])
    }

    func test_methodStep_whenStoredWithDoneBy_shouldShowDoneBy() {
        let stored = sut.instructionStep(for: MethodStep(kind: .pour, amount: .upTo(300), time: .doneBy(75)), dose: dose, duration: 30)

        let result = sut.methodStep(from: stored, dose: dose)

        XCTAssertEqual(result.time, .doneBy(75))
    }

    func test_methodStep_whenOldEditorAmountWithZeroAdjustment_shouldBeExpressible() {
        let old = loadOldEditorV60Instructions().steps[1] // 1 × #total.coffee + 0 × #current.coffee

        let result = sut.methodStep(from: old, dose: ReferenceDose(coffee: 15, water: 250))

        XCTAssertNil(result.legacy)
        XCTAssertEqual(result.kind, .addCoffee)
        XCTAssertEqual(result.amount, .add(15))
        XCTAssertEqual(result.customText, "Put all #current.amount g of coffee to brewer")
    }

    func test_methodStep_whenWaterIsAShareOfCoffee_shouldKeepTheStepAsStored() {
        let old = loadOldEditorV60Instructions().steps[3] // water = 2 × #total.coffee

        let result = sut.methodStep(from: old, dose: ReferenceDose(coffee: 15, water: 250))
        let savedAgain = sut.instructionStep(for: result, dose: ReferenceDose(coffee: 20, water: 320), duration: nil)

        XCTAssertNotNil(result.legacy)
        XCTAssertEqual(result.kind, .pour)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        XCTAssertEqual(try encoder.encode(savedAgain), try encoder.encode(old))
    }

    func test_methodStep_whenPauseWithoutCountdown_shouldKeepTheStepAsStored() {
        let pause = RecipeInstructionStep(
            action: .pause,
            instructionAction: PauseInstructionAction(requirement: nil, startMethod: .auto, skipMethod: .auto, message: "Hold", details: nil)
        )

        XCTAssertNotNil(sut.methodStep(from: pause, dose: dose).legacy)
    }

    func test_decode_whenStepHasKindAndDoneBy_shouldStillBrewTheSame() throws {
        let json = ##"{"action":"put","kind":"pour","doneBy":75,"ingredient":"water","amount":{"type":"millilitre","factor":0.6,"factorOf":"water","adjustment":{"factor":-1,"factorOf":"#current.water"}},"requirement":{"type":"countdown","duration":{"type":"second","length":30}},"startMethod":"auto","skipMethod":"auto","message":"Pour up to #current.water g"}"##

        let step = try JSONDecoder().decode(RecipeInstructionStep.self, from: Data(json.utf8))
        let coffee = sut.instructionStep(for: MethodStep(kind: .addCoffee, amount: .add(30)), dose: dose, duration: nil)
        let stages = MethodDraftCompiler.evaluate(steps: [coffee, step], dose: ReferenceDose(coffee: 30, water: 500))

        XCTAssertEqual(step.kind, "pour")
        XCTAssertEqual(step.doneBy, 75)
        XCTAssertEqual(stages.last??.action, .pourWater(.init(amount: 300, type: .millilitre)))
        XCTAssertEqual(stages.last??.requirement, .countdown(30))
    }

    /// Before any step puts something in, the engine has no running total, so "Up to" there is stored as an added amount.
    func test_compile_whenFirstStepIsUpTo_shouldBrewTheFullAmountAndReopenAsUpTo() {
        let draft = MethodDraft(name: "Kalita", iconName: "", coffee: 20, water: 320, ice: nil,
                                steps: [MethodStep(kind: .pour, amount: .upTo(50)), MethodStep(kind: .pour, amount: .upTo(320))],
                                origin: .scratch)

        let stored = MethodDraftCompiler().instructionSteps(for: draft)
        let preview = MethodDraftCompiler().preview(for: draft)
        let reopened = stored.map { sut.methodStep(from: $0, dose: draft.referenceDose) }

        XCTAssertEqual(preview.steps.map(\.addedGrams), [50, 270])
        XCTAssertEqual(preview.steps.map(\.text), ["Pour up to 50 g", "Pour up to 320 g"])
        XCTAssertEqual(reopened.map(\.amount), [.upTo(50), .upTo(320)])
        XCTAssertEqual(reopened.map(\.customText), [nil, nil])
    }
}
