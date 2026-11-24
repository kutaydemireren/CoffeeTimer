//
//  MethodStepMapper.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation

/// Converts between editor steps (grams for a reference dose) and stored instruction steps (factors).
///
/// Grams become factors of the recipe's totals, so a method scales to any recipe:
/// - Up to 300 g in a 500 g method: `0.6 × water − 1 × #current.water`
/// - Add 50 g in a 500 g method: `0.1 × water` (coffee and ice use their own totals)
/// - The rest: `1 × #remaining.water`
///
/// The engine only knows the water poured so far (`#current.water`) once a step has put something in or paused.
/// Before that, "Up to" is stored as an added amount, which is the same number there, and `amountMode` keeps it "Up to" in the editor.
protocol MethodStepMapper {
    func instructionStep(for step: MethodStep, dose: ReferenceDose, duration: UInt?, hasRunningTotal: Bool) -> RecipeInstructionStep
    func methodStep(from instructionStep: RecipeInstructionStep, dose: ReferenceDose) -> MethodStep
}

struct MethodStepMapperImp: MethodStepMapper {
    // MARK: Editor → stored

    func instructionStep(for step: MethodStep, dose: ReferenceDose, duration: UInt?, hasRunningTotal: Bool = true) -> RecipeInstructionStep {
        if let legacyStep = step.legacy?.step {
            return legacyStep
        }

        let requirement: InstructionRequirement? = duration.map { .countdown($0) }
        let startMethod: InstructionInteractionMethod = (duration != nil && step.startsByItself) ? .auto : .userInteractive
        let skipMethod: InstructionInteractionMethod = (duration != nil && step.then == .carryOn) ? .auto : .userInteractive
        let message = MethodStepText.message(for: step, duration: duration)
        let tip = step.tip.trimmingCharacters(in: .whitespacesAndNewlines)
        let details: String? = tip.isEmpty ? nil : step.tip
        var doneBy: UInt?
        if case .doneBy(let seconds) = step.time { doneBy = seconds }

        let instructionAction: InstructionAction
        let action: RecipeInstructionStep.Action
        var amountMode: String?
        switch step.kind {
        case .pour, .addCoffee, .addIce:
            action = .put
            let ingredient = step.kind.ingredient ?? .water
            var stepAmount = step.amount ?? .add(0)
            amountMode = stepAmount.mode.rawValue
            if case .upTo(let grams) = stepAmount, !hasRunningTotal {
                stepAmount = .add(grams)
            }
            instructionAction = PutInstructionAction(
                requirement: requirement,
                startMethod: startMethod,
                skipMethod: skipMethod,
                message: message,
                details: details,
                ingredient: ingredient.rawValue,
                amount: amount(for: stepAmount, ingredient: ingredient, dose: dose)
            )
        case .wait:
            action = .pause
            instructionAction = PauseInstructionAction(
                requirement: requirement,
                startMethod: startMethod,
                skipMethod: skipMethod,
                message: message,
                details: details
            )
        case .swirl, .note, .press, .flip, .remove:
            action = .message
            instructionAction = MessageInstructionAction(
                requirement: requirement,
                startMethod: startMethod,
                skipMethod: skipMethod,
                message: message,
                details: details
            )
        }

        return RecipeInstructionStep(action: action, instructionAction: instructionAction, kind: step.kind.rawValue, doneBy: doneBy, amountMode: amountMode)
    }

    func amount(for amount: StepAmount, ingredient: MethodIngredient, dose: ReferenceDose) -> InstructionAmount {
        let type: IngredientAmountTypeDTO = ingredient == .water ? .millilitre : .gram
        let reference: Double
        switch ingredient {
        case .water: reference = dose.water
        case .coffee: reference = dose.coffee
        case .ice: reference = dose.ice ?? 0
        }

        func share(_ grams: Double) -> Double {
            guard reference > 0 else { return 0 }
            return grams / reference
        }

        switch amount {
        case .upTo(let grams) where ingredient == .water:
            return InstructionAmount(
                type: type,
                mainFactor: .init(factor: share(grams), factorOf: InstructionKeyword.water.keyword),
                adjustmentFactor: .init(factor: -1, factorOf: InstructionKeyword.currentWater.keyword)
            )
        case .rest where ingredient == .water:
            return InstructionAmount(
                type: type,
                mainFactor: .init(factor: 1, factorOf: InstructionKeyword.remainingWater.keyword),
                adjustmentFactor: nil
            )
        case .upTo(let grams), .add(let grams):
            return InstructionAmount(
                type: type,
                mainFactor: .init(factor: share(grams), factorOf: ingredient.rawValue),
                adjustmentFactor: nil
            )
        case .rest:
            return InstructionAmount(type: type, mainFactor: .init(factor: 0, factorOf: ingredient.rawValue), adjustmentFactor: nil)
        }
    }

    // MARK: Stored → editor

    func methodStep(from instructionStep: RecipeInstructionStep, dose: ReferenceDose) -> MethodStep {
        let storedKind = instructionStep.kind.flatMap(MethodStepKind.init(rawValue:))

        switch instructionStep.instructionAction {
        case let put as PutInstructionAction:
            guard let ingredient = put.ingredient.flatMap(MethodIngredient.init(rawValue:)),
                  var amount = stepAmount(from: put.amount, ingredient: ingredient, dose: dose) else {
                return legacy(instructionStep, kind: kind(forIngredient: put.ingredient))
            }
            if ingredient == .water, instructionStep.amountMode == StepAmountMode.upTo.rawValue, case .add(let grams) = amount {
                amount = .upTo(grams)
            }
            let kind = kind(forIngredient: put.ingredient)
            return expressible(instructionStep, action: put, kind: kind, amount: amount)

        case let pause as PauseInstructionAction:
            guard case .countdown? = pause.requirement else {
                return legacy(instructionStep, kind: .wait)
            }
            return expressible(instructionStep, action: pause, kind: .wait, amount: nil)

        case let message as MessageInstructionAction:
            let kind: MethodStepKind
            if let storedKind, !storedKind.hasAmount, storedKind != .wait {
                kind = storedKind
            } else {
                kind = .note
            }
            return expressible(instructionStep, action: message, kind: kind, amount: nil)

        default:
            return legacy(instructionStep, kind: .note)
        }
    }

    private func kind(forIngredient ingredient: String?) -> MethodStepKind {
        switch ingredient {
        case MethodIngredient.coffee.rawValue: return .addCoffee
        case MethodIngredient.ice.rawValue: return .addIce
        default: return .pour
        }
    }

    private func expressible(_ instructionStep: RecipeInstructionStep, action: InstructionAction, kind: MethodStepKind, amount: StepAmount?) -> MethodStep {
        var countdown: UInt?
        if case .countdown(let seconds)? = action.requirement, seconds > 0 {
            countdown = seconds
        }

        let time: StepTime
        if let countdown {
            if let doneBy = instructionStep.doneBy {
                time = .doneBy(doneBy)
            } else {
                time = .takes(min(countdown, MethodTimeline.maximumSeconds))
            }
        } else {
            time = .none
        }

        let then: StepThen = countdown == nil
            ? MethodStep.defaultThen(for: kind, time: time)
            : (action.skipMethod == .auto ? .carryOn : .waitForTap)

        var step = MethodStep(
            kind: kind,
            amount: amount,
            time: time,
            then: then,
            customText: nil,
            tip: action.details ?? "",
            startsByItself: countdown == nil ? true : action.startMethod == .auto
        )

        let message = action.message ?? ""
        if message != MethodStepText.generated(for: step, duration: countdown) {
            step.customText = message
        }
        return step
    }

    private func legacy(_ instructionStep: RecipeInstructionStep, kind: MethodStepKind) -> MethodStep {
        // The fields below are what the step sheet starts from if the user edits the step.
        // Until then, the step is saved exactly as stored. The amount is filled in by the caller, which knows the running totals.
        let action = instructionStep.instructionAction
        var countdown: UInt?
        if case .countdown(let seconds)? = action?.requirement, seconds > 0 {
            countdown = min(seconds, MethodTimeline.maximumSeconds)
        }
        let time: StepTime = countdown.map { .takes($0) } ?? (kind == .wait ? .takes(30) : .none)
        return MethodStep(
            kind: kind,
            amount: nil,
            time: time,
            then: countdown == nil ? nil : (action?.skipMethod == .auto ? .carryOn : .waitForTap),
            customText: action?.message,
            tip: action?.details ?? "",
            startsByItself: countdown == nil ? true : action?.startMethod == .auto,
            legacy: LegacyStep(step: instructionStep)
        )
    }

    /// The grams a stored amount stands for at `dose`, or `nil` when the editor fields can't express it.
    private func stepAmount(from amount: InstructionAmount?, ingredient: MethodIngredient, dose: ReferenceDose) -> StepAmount? {
        guard let main = amount?.mainFactor, let factor = main.factor, let factorOf = main.factorOf else { return nil }
        let adjustment = amount?.adjustmentFactor
        let hasAdjustment = (adjustment?.factor ?? 0) != 0 && adjustment?.factorOf != nil

        switch ingredient {
        case .water:
            let isTotalWater = factorOf == InstructionKeyword.water.keyword || factorOf == InstructionKeyword.totalWater.keyword
            if isTotalWater && !hasAdjustment {
                return .add(factor * dose.water)
            }
            if isTotalWater, adjustment?.factor == -1, adjustment?.factorOf == InstructionKeyword.currentWater.keyword {
                return .upTo(factor * dose.water)
            }
            if factorOf == InstructionKeyword.remainingWater.keyword, factor == 1, !hasAdjustment {
                return .rest
            }
            return nil
        case .coffee:
            let isTotalCoffee = factorOf == InstructionKeyword.coffee.keyword || factorOf == InstructionKeyword.totalCoffee.keyword
            guard isTotalCoffee, !hasAdjustment else { return nil }
            return .add(factor * dose.coffee)
        case .ice:
            guard factorOf == InstructionKeyword.ice.keyword, !hasAdjustment, let ice = dose.ice else { return nil }
            return .add(factor * ice)
        }
    }
}
