//
//  MethodDraftFactoryTests.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import XCTest
@testable import CoffeeTimer

final class MethodDraftFactoryTests: XCTestCase {
    private var sut: MethodDraftFactory!

    override func setUp() {
        sut = MethodDraftFactory()
    }

    // MARK: Old custom methods

    func test_draftEditing_whenOldMethod_shouldShowStepsInGramsAt15And250() {
        let draft = sut.draft(editing: .oldCustom, instructions: loadOldEditorV60Instructions())

        XCTAssertEqual(draft.coffee, 15)
        XCTAssertEqual(draft.water, 250)
        XCTAssertNil(draft.ice)
        XCTAssertEqual(draft.name, "Old V60 Mine")
        XCTAssertEqual(draft.editedMethodId, BrewMethod.oldCustom.id)
        XCTAssertEqual(draft.steps.map(\.kind), [.note, .addCoffee, .note, .pour, .note, .wait, .pour, .wait, .pour, .note])
        XCTAssertEqual(draft.steps[1].amount, .add(15))
        XCTAssertEqual(draft.steps[6].amount, .upTo(150))
        XCTAssertEqual(draft.steps[6].time, .takes(30))
        XCTAssertEqual(draft.steps[8].amount, .rest)

        let preview = MethodDraftCompiler().preview(for: draft)
        XCTAssertEqual(preview.steps.map(\.addedGrams), [nil, 15, nil, 30, nil, nil, 120, nil, 100, nil])
        XCTAssertEqual(preview.pouredWater, 250)
        XCTAssertEqual(preview.timeline.total, 100)
    }

    func test_draftEditing_whenOldStepCannotBeExpressed_shouldKeepItAndStartTheSheetFromItsGrams() {
        let draft = sut.draft(editing: .oldCustom, instructions: loadOldEditorV60Instructions())

        let bloom = draft.steps[3] // 2 × #total.coffee
        XCTAssertNotNil(bloom.legacy)
        XCTAssertEqual(bloom.amount, .add(30))
        XCTAssertEqual(draft.steps.filter { $0.legacy != nil }.count, 1)
    }

    /// Saving an old method converts it. Recipes made from it afterwards brew the same steps, amounts and timers as before.
    func test_savedDraft_whenOldMethodOpenedAndSaved_shouldBrewExactlyAsBefore() {
        let original = loadOldEditorV60Instructions()
        let draft = sut.draft(editing: .oldCustom, instructions: original)

        let converted = MethodDraftCompiler().instructionSteps(for: draft)

        for dose in [ReferenceDose(coffee: 15, water: 250), ReferenceDose(coffee: 29, water: 500), ReferenceDose(coffee: 47, water: 800)] {
            let before = MethodDraftCompiler.evaluate(steps: original.steps, dose: dose)
            let after = MethodDraftCompiler.evaluate(steps: converted, dose: dose)
            XCTAssertEqual(after.map { $0?.action }, before.map { $0?.action })
            XCTAssertEqual(after.map { $0?.requirement }, before.map { $0?.requirement })
            XCTAssertEqual(after.map { $0?.startMethod }, before.map { $0?.startMethod })
            XCTAssertEqual(after.map { $0?.passMethod }, before.map { $0?.passMethod })
            // Saved text now says g where it said ml; the brew screen already showed g.
            XCTAssertEqual(after.map { $0?.message.brewDisplayText }, before.map { $0?.message.brewDisplayText })
            XCTAssertEqual(after.map { ($0?.details ?? "").brewDisplayText }, before.map { ($0?.details ?? "").brewDisplayText })
        }
    }

    func test_brewMethod_whenOldMethodSavedInPlace_shouldKeepIdRatiosAndCupsAndSetReferenceDose() {
        let draft = sut.draft(editing: .oldCustom, instructions: loadOldEditorV60Instructions())

        let result = sut.brewMethod(from: draft, id: BrewMethod.oldCustom.id)

        XCTAssertEqual(result.id, BrewMethod.oldCustom.id)
        XCTAssertEqual(result.path, BrewMethod.oldCustom.path)
        XCTAssertEqual(result.ratios, BrewMethod.oldCustom.ratios)
        XCTAssertEqual(result.cupsCount, BrewMethod.oldCustom.cupsCount)
        XCTAssertEqual(result.referenceDose, ReferenceDose(coffee: 15, water: 250))
        XCTAssertEqual(result.recipeRatios.first?.title, "1:16.7 - As written")
    }

    func test_dose_whenOldIcedMethod_shouldKeepTheFortyPercentIceShare() {
        var iced = BrewMethod.oldCustom
        iced = BrewMethod(id: iced.id, iconName: iced.iconName, title: iced.title, path: iced.path, isIcedBrew: true, cupsCount: iced.cupsCount, ratios: iced.ratios, info: iced.info)

        let dose = MethodDraftFactory.dose(for: iced)

        XCTAssertEqual(dose.ice, 167)
        XCTAssertEqual(dose.iceToWaterShare! / (1 + dose.iceToWaterShare!), 0.4, accuracy: 0.001)
    }

    // MARK: Make it mine

    func test_draftCopying_whenBuiltIn_shouldNameItMineAndKeepIconAndSteps() {
        let instructions = loadMiniInstructions()

        let draft = sut.draft(copying: .v60Single, instructions: instructions)

        XCTAssertEqual(draft.name, "My V60 Single")
        XCTAssertEqual(draft.iconName, "recipe-profile-v60")
        XCTAssertEqual(draft.origin, .copy(of: "v60-single"))
        XCTAssertNil(draft.editedMethodId)
        XCTAssertEqual(draft.steps.count, instructions.steps.count)
        XCTAssertEqual(draft.coffee, 15)
        XCTAssertEqual(draft.water, 250)
    }

    func test_draftCopying_whenOwnMethod_shouldNameItACopyAndKeepItsDose() {
        var own = BrewMethod.oldCustom
        own.referenceDose = ReferenceDose(coffee: 30, water: 500)

        let draft = sut.draft(copying: own, instructions: loadOldEditorV60Instructions())

        XCTAssertEqual(draft.name, "Old V60 Mine copy")
        XCTAssertEqual(draft.coffee, 30)
        XCTAssertEqual(draft.water, 500)
    }

    func test_draftCopying_whenCopyNameIsTaken_shouldNumberIt() {
        let draft = sut.draft(copying: .v60Single, instructions: loadMiniInstructions(), existingTitles: ["V60 Single", "My V60 Single"])

        XCTAssertEqual(draft.name, "My V60 Single 2")
    }

    // MARK: Copy names

    func test_copyName_whenBuiltInAndNameIsFree_shouldBeMyMethod() {
        let name = MethodDraftFactory.copyName(for: .v60Single, among: ["V60 Single", "Chemex"])

        XCTAssertEqual(name, "My V60 Single")
    }

    func test_copyName_whenBuiltInCopiedOnce_shouldAdd2() {
        let name = MethodDraftFactory.copyName(for: .v60Single, among: ["V60 Single", "My V60 Single"])

        XCTAssertEqual(name, "My V60 Single 2")
    }

    func test_copyName_whenBuiltInCopiedTwice_shouldAdd3() {
        let name = MethodDraftFactory.copyName(for: .v60Single, among: ["My V60 Single", "My V60 Single 2"])

        XCTAssertEqual(name, "My V60 Single 3")
    }

    func test_copyName_whenANumberIsFree_shouldUseTheFirstFreeOne() {
        let name = MethodDraftFactory.copyName(for: .v60Single, among: ["My V60 Single", "My V60 Single 3"])

        XCTAssertEqual(name, "My V60 Single 2")
    }

    func test_copyName_whenOnlyANumberedCopyExists_shouldUseThePlainName() {
        let name = MethodDraftFactory.copyName(for: .v60Single, among: ["My V60 Single 2"])

        XCTAssertEqual(name, "My V60 Single")
    }

    func test_copyName_whenTakenWithOtherCaseOrSpaces_shouldStillNumberIt() {
        let name = MethodDraftFactory.copyName(for: .v60Single, among: [" my v60 single "])

        XCTAssertEqual(name, "My V60 Single 2")
    }

    func test_copyName_whenOwnMethodCopiedBefore_shouldNumberTheCopy() {
        let name = MethodDraftFactory.copyName(for: .oldCustom, among: ["Old V60 Mine", "Old V60 Mine copy"])

        XCTAssertEqual(name, "Old V60 Mine copy 2")
    }

    func test_brewMethod_whenNew_shouldBeACustomMethodWithItsOwnRatioFirst() {
        var draft = MethodDraft.scratch()
        draft.name = " Kalita Wave "
        draft.coffee = 20
        draft.water = 320
        draft.steps = [MethodStep(kind: .pour, amount: .rest)]

        let result = sut.brewMethod(from: draft, id: "new-id")

        XCTAssertEqual(result.title, "Kalita Wave")
        XCTAssertEqual(result.path, "custom-method://new-id")
        XCTAssertEqual(result.iconName, MethodDraft.kettleIcon)
        XCTAssertFalse(result.isIcedBrew)
        XCTAssertEqual(result.defaultRatio?.title, "1:16 - As written")
        XCTAssertEqual(result.recipeRatios.first, result.defaultRatio)
    }

    func test_brewMethod_whenAddsIce_shouldBeIcedWithItsIceShare() {
        var draft = MethodDraft.scratch()
        draft.name = "Iced"
        draft.coffee = 15
        draft.water = 150
        draft.ice = 100
        draft.steps = [MethodStep(kind: .addIce, amount: .add(100)), MethodStep(kind: .pour, amount: .rest)]

        let result = sut.brewMethod(from: draft, id: "iced")

        XCTAssertTrue(result.isIcedBrew)
        XCTAssertEqual(result.referenceDose, ReferenceDose(coffee: 15, water: 150, ice: 100))
        XCTAssertEqual(result.ratios, StaticCoffeetoWaterRatioGenerator.icedBrew())
    }

    func test_draft_shouldShowAndSaveWaterInGramsButKeepUneditedKeptStepsAsStored() {
        let original = loadOldEditorV60Instructions()
        let draft = sut.draft(editing: .oldCustom, instructions: original)

        let pour = draft.steps[6]
        XCTAssertEqual(pour.customText, "Pour #current.amount g of water in ~30 seconds")
        XCTAssertEqual(pour.tip, "Remember to pour gently in cycles\nTotal: #current.water g of water")
        XCTAssertEqual(draft.steps[2].tip, "Boil more than #total.water g of water")

        let saved = MethodDraftCompiler().instructionSteps(for: draft)
        XCTAssertEqual(saved[6].instructionAction?.message, "Pour #current.amount g of water in ~30 seconds")
        // The bloom is kept as stored until edited, so it still says ml.
        XCTAssertEqual(saved[3].instructionAction?.message, "To bloom, gently pour #current.amount ml of water")
        // Once edited, it says g too.
        XCTAssertEqual(draft.steps[3].customText, "To bloom, gently pour #current.amount g of water")
    }

    func test_waterInGrams_shouldOnlyChangeMillilitresAfterANumberOrToken() {
        XCTAssertEqual("Pour 50 ml and #current.water ml, 30ml".waterInGrams, "Pour 50 g and #current.water g, 30 g")
        XCTAssertEqual("Use a small bowl of ml-free text".waterInGrams, "Use a small bowl of ml-free text")
    }
}
