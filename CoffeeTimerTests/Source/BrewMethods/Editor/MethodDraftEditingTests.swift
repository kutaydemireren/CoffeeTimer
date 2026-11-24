//
//  MethodDraftEditingTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class MethodTimelineTests: XCTestCase {
    func test_init_whenDoneBy_shouldCountdownFromThePlannedStart() {
        let steps = [
            MethodStep(kind: .pour, amount: .add(60), time: .takes(15)),
            MethodStep(kind: .wait, time: .takes(30)),
            MethodStep(kind: .pour, amount: .upTo(300), time: .doneBy(75)),
            MethodStep(kind: .pour, amount: .rest, time: .doneBy(105))
        ]

        let timeline = MethodTimeline(steps: steps)

        XCTAssertEqual(timeline.entries.map(\.start), [0, 15, 45, 75])
        XCTAssertEqual(timeline.entries.map(\.duration), [15, 30, 30, 30])
        XCTAssertEqual(timeline.total, 105)
    }

    func test_init_whenStepsWaitForATap_shouldCountThemAsZeroSeconds() {
        let steps = [
            MethodStep(kind: .addCoffee, amount: .add(15)),
            MethodStep(kind: .pour, amount: .add(50)),
            MethodStep(kind: .wait, time: .takes(30)),
            MethodStep(kind: .swirl),
            MethodStep(kind: .pour, amount: .rest, time: .doneBy(90))
        ]

        let timeline = MethodTimeline(steps: steps)

        XCTAssertEqual(timeline.entries.map(\.start), [0, 0, 0, 30, 30])
        XCTAssertEqual(timeline.entries[4].duration, 60)
        XCTAssertEqual(timeline.total, 90)
    }

    func test_init_whenDoneByIsNotAfterTheStart_shouldBeInvalidAndCountZero() {
        let steps = [
            MethodStep(kind: .wait, time: .takes(60)),
            MethodStep(kind: .pour, amount: .rest, time: .doneBy(45)),
            MethodStep(kind: .wait, time: .takes(10))
        ]

        let timeline = MethodTimeline(steps: steps)

        XCTAssertFalse(timeline.entries[1].isValid)
        XCTAssertNil(timeline.entries[1].duration)
        XCTAssertEqual(timeline.entries[2].start, 60)
        XCTAssertEqual(timeline.total, 70)
    }

    func test_init_whenEarlierStepChanges_shouldRecomputeDoneByDuration() {
        var steps = [
            MethodStep(kind: .wait, time: .takes(30)),
            MethodStep(kind: .pour, amount: .rest, time: .doneBy(90))
        ]
        XCTAssertEqual(MethodTimeline(steps: steps).entries[1].duration, 60)

        steps[0].time = .takes(45)

        XCTAssertEqual(MethodTimeline(steps: steps).entries[1].duration, 45)
    }
}

final class MethodTimeFormatTests: XCTestCase {
    func test_clockAndShort() {
        XCTAssertEqual(MethodTimeFormat.clock(75), "1:15")
        XCTAssertEqual(MethodTimeFormat.clock(3600), "60:00")
        XCTAssertEqual(MethodTimeFormat.short(30), "30 s")
        XCTAssertEqual(MethodTimeFormat.short(90), "1:30")
    }

    func test_parse_shouldReadMinutesAndSeconds() {
        XCTAssertEqual(MethodTimeFormat.parse("1:15"), 75)
        XCTAssertEqual(MethodTimeFormat.parse("75"), 75)
        XCTAssertEqual(MethodTimeFormat.parse("60:00"), 3600)
        XCTAssertEqual(MethodTimeFormat.parse("2:"), 120)
        XCTAssertEqual(MethodTimeFormat.parse(":30"), 30)
        XCTAssertNil(MethodTimeFormat.parse("1:75"))
        XCTAssertNil(MethodTimeFormat.parse("1:2:3"))
        XCTAssertNil(MethodTimeFormat.parse("abc"))
        XCTAssertNil(MethodTimeFormat.parse(""))
    }
}

final class MethodStepTextTests: XCTestCase {
    func test_generated_shouldUseTokensSoNumbersStayLive() {
        XCTAssertEqual(MethodStepText.generated(for: MethodStep(kind: .pour, amount: .upTo(150)), duration: nil), "Pour up to #current.water g")
        XCTAssertEqual(MethodStepText.generated(for: MethodStep(kind: .pour, amount: .add(50)), duration: nil), "Pour #current.amount g")
        XCTAssertEqual(MethodStepText.generated(for: MethodStep(kind: .pour, amount: .rest), duration: nil), "Pour the rest, #current.amount g")
        XCTAssertEqual(MethodStepText.generated(for: MethodStep(kind: .addCoffee, amount: .add(15)), duration: nil), "Add #current.amount g of coffee")
        XCTAssertEqual(MethodStepText.generated(for: MethodStep(kind: .wait, time: .takes(45)), duration: 45), "Wait 45 s")
        XCTAssertEqual(MethodStepText.generated(for: MethodStep(kind: .swirl), duration: nil), "Swirl or stir")
    }

    func test_generatedLine_whenRecipeIsScaled_shouldShowTheRecipeNumbers() {
        let draft = MethodDraft(
            name: "V60", iconName: "", coffee: 15, water: 250, ice: nil,
            steps: [MethodStep(kind: .pour, amount: .upTo(150)), MethodStep(kind: .pour, amount: .rest)],
            origin: .scratch
        )
        let steps = MethodDraftCompiler().instructionSteps(for: draft)

        let stages = MethodDraftCompiler.evaluate(steps: steps, dose: ReferenceDose(coffee: 30, water: 500))

        XCTAssertEqual(stages.map { $0?.message.brewDisplayText }, ["Pour up to 300 g", "Pour the rest, 200 g"])
    }

    func test_placeholders_roundTrip() {
        let tokens = "Pour #current.amount g, up to #current.water g of #total.water g"

        let placeholders = MethodStepText.placeholders(fromTokens: tokens)

        XCTAssertEqual(placeholders, "Pour {amount} g, up to {total} g of {water} g")
        XCTAssertEqual(MethodStepText.tokens(fromPlaceholders: placeholders), tokens)
    }

    func test_customText_shouldBeSavedWithTokensAndBrewWithNumbers() {
        var step = MethodStep(kind: .pour, amount: .add(60))
        step.customText = MethodStepText.tokens(fromPlaceholders: "Bloom with {amount} g")
        let draft = MethodDraft(name: "V60", iconName: "", coffee: 30, water: 500, ice: nil, steps: [step], origin: .scratch)

        let stored = MethodDraftCompiler().instructionSteps(for: draft)
        let preview = MethodDraftCompiler().preview(for: draft)

        XCTAssertEqual(stored.first?.instructionAction?.message, "Bloom with #current.amount g")
        XCTAssertEqual(preview.steps.first?.text, "Bloom with 60 g")
    }
}

final class MethodDraftEditingTests: XCTestCase {
    private func draft(steps: [MethodStep], name: String = "Mine", coffee: Double = 20, water: Double = 320, ice: Double? = nil) -> MethodDraft {
        MethodDraft(name: name, iconName: MethodDraft.kettleIcon, coffee: coffee, water: water, ice: ice, steps: steps, origin: .scratch)
    }

    // MARK: Scaling

    func test_updatingDose_whenScaling_shouldScaleAmountsAndKeepTimes() {
        let original = draft(steps: [
            MethodStep(kind: .addCoffee, amount: .add(15)),
            MethodStep(kind: .pour, amount: .add(50), time: .takes(10)),
            MethodStep(kind: .pour, amount: .upTo(150), time: .doneBy(75)),
            MethodStep(kind: .pour, amount: .rest)
        ], coffee: 15, water: 250)

        let result = original.updatingDose(coffee: 30, water: 500, ice: nil, scaleSteps: true)

        XCTAssertEqual(result.coffee, 30)
        XCTAssertEqual(result.water, 500)
        XCTAssertEqual(result.steps.map(\.amount), [.add(30), .add(100), .upTo(300), .rest])
        XCTAssertEqual(result.steps.map(\.time), original.steps.map(\.time))
    }

    func test_updatingDose_whenScaling_shouldRoundToTheGram() {
        let original = draft(steps: [MethodStep(kind: .pour, amount: .add(50))], coffee: 15, water: 250)

        let result = original.updatingDose(coffee: 20, water: 333, ice: nil, scaleSteps: true)

        XCTAssertEqual(result.steps.first?.amount, .add(67))
    }

    func test_updatingDose_whenNotScaling_shouldKeepTheGrams() {
        let original = draft(steps: [MethodStep(kind: .pour, amount: .upTo(150))], coffee: 15, water: 250)

        let result = original.updatingDose(coffee: 30, water: 500, ice: nil, scaleSteps: false)

        XCTAssertEqual(result.steps.first?.amount, .upTo(150))
    }

    func test_updatingDose_shouldLeaveKeptStepsAlone() {
        let legacy = MethodStepMapperImp().methodStep(from: loadOldEditorV60Instructions().steps[3], dose: ReferenceDose(coffee: 15, water: 250))
        let original = draft(steps: [legacy], coffee: 15, water: 250)

        let result = original.updatingDose(coffee: 30, water: 500, ice: nil, scaleSteps: true)

        XCTAssertEqual(result.steps.first, legacy)
    }

    // MARK: Validation

    func test_validationIssues_whenEmpty_shouldAskForNameAndStep() {
        let issues = draft(steps: [], name: " ").validationIssues

        XCTAssertEqual(issues, [.missingName, .missingSteps])
        XCTAssertEqual(issues.map(\.message), ["Add a name", "Add at least one step"])
    }

    func test_validationIssues_whenNoteEmpty_shouldNameTheStep() {
        let issues = draft(steps: [MethodStep(kind: .swirl), MethodStep(kind: .note, customText: "")]).validationIssues

        XCTAssertEqual(issues, [.emptyNote(step: 2)])
        XCTAssertEqual(issues.first?.message, "Write the note in step 2")
    }

    func test_validationIssues_whenDoneByIsTooEarly_shouldExplainWhenTheStepStarts() {
        let issues = draft(steps: [
            MethodStep(kind: .wait, time: .takes(60)),
            MethodStep(kind: .pour, amount: .rest, time: .doneBy(45))
        ]).validationIssues

        XCTAssertEqual(issues, [.doneByTooEarly(step: 2, start: 60)])
        XCTAssertEqual(issues.first?.message, "Step 2 starts at 1:00, so \"Done by\" must be later")
    }

    func test_validationIssues_whenAmountIsZero_shouldAskForAnAmount() {
        let issues = draft(steps: [MethodStep(kind: .pour, amount: .add(0))]).validationIssues

        XCTAssertEqual(issues.map(\.message), ["Set an amount in step 1"])
    }

    func test_validationIssues_whenDoseMissing_shouldAskForIt() {
        let issues = draft(steps: [MethodStep(kind: .swirl)], coffee: 0).validationIssues

        XCTAssertEqual(issues.map(\.message), ["Set the coffee and water it is written for"])
    }

    func test_validationIssues_whenValid_shouldBeEmpty() {
        XCTAssertTrue(draft(steps: [MethodStep(kind: .pour, amount: .rest, time: .doneBy(60))]).validationIssues.isEmpty)
    }

    // MARK: Fixes and defaults

    func test_makingLastPourTheRest_shouldBalanceTheWater() {
        let original = draft(steps: [
            MethodStep(kind: .pour, amount: .upTo(50)),
            MethodStep(kind: .pour, amount: .upTo(200)),
            MethodStep(kind: .swirl)
        ])
        XCTAssertFalse(MethodDraftCompiler().preview(for: original).waterMatches)

        let result = original.makingLastPourTheRest()

        XCTAssertEqual(result.steps[1].amount, .rest)
        let preview = MethodDraftCompiler().preview(for: result)
        XCTAssertTrue(preview.waterMatches)
        XCTAssertEqual(preview.pouredWater, 320)
    }

    func test_newStep_shouldUseDefaultsPerKind() {
        let base = draft(steps: [])

        XCTAssertEqual(base.newStep(kind: .wait, at: 0).time, .takes(30))
        XCTAssertEqual(base.newStep(kind: .wait, at: 0).then, .carryOn)
        XCTAssertEqual(base.newStep(kind: .pour, at: 0).then, .waitForTap)
        XCTAssertEqual(base.newStep(kind: .pour, at: 0).amount, .upTo(320))
        XCTAssertEqual(base.newStep(kind: .addCoffee, at: 0).amount, .add(20))
        XCTAssertNil(base.newStep(kind: .note, at: 0).amount)
    }
}
