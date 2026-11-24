//
//  MethodDraftCompiler.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation

/// What the editor shows for one step, taken from the real step engine at the reference dose.
struct MethodStepPreview: Equatable {
    /// The brew-screen line, as the brew screen will show it.
    let text: String
    let tip: String?
    /// Grams this step puts in, for Pour, Add coffee and Add ice.
    let addedGrams: UInt?
    let ingredient: MethodIngredient?
    /// Water poured so far, after this step.
    let waterTotal: UInt
    let timing: MethodTimeline.Entry
}

struct MethodPreview: Equatable {
    let steps: [MethodStepPreview]
    let timeline: MethodTimeline
    /// Water the method is written for.
    let water: UInt

    /// Water all steps pour together.
    var pouredWater: UInt { steps.last?.waterTotal ?? 0 }

    var waterMatches: Bool { pouredWater == water }
}

/// Turns a draft into stored instructions, and previews it by running the step engine at the draft's reference dose.
struct MethodDraftCompiler {
    var mapper: MethodStepMapper = MethodStepMapperImp()

    func instructionSteps(for draft: MethodDraft) -> [RecipeInstructionStep] {
        let timeline = MethodTimeline(steps: draft.steps)
        var hasRunningTotal = false
        return zip(draft.steps, timeline.entries).map { step, entry in
            let stored = mapper.instructionStep(for: step, dose: draft.referenceDose, duration: entry.duration, hasRunningTotal: hasRunningTotal)
            hasRunningTotal = hasRunningTotal || MethodDraftCompiler.setsRunningTotal(stored)
            return stored
        }
    }

    func preview(for draft: MethodDraft) -> MethodPreview {
        let timeline = MethodTimeline(steps: draft.steps)
        let stages = MethodDraftCompiler.evaluate(steps: instructionSteps(for: draft), dose: draft.referenceDose)

        var waterTotal: UInt = 0
        var previews: [MethodStepPreview] = []
        for (index, stage) in stages.enumerated() {
            var added: UInt?
            var ingredient: MethodIngredient?
            switch stage?.action {
            case .pourWater(let amount)?:
                added = amount.amount
                ingredient = .water
                waterTotal += amount.amount
            case .putCoffee(let amount)?:
                added = amount.amount
                ingredient = .coffee
            case .putIce(let amount)?:
                added = amount.amount
                ingredient = .ice
            default:
                break
            }
            let tip = stage?.details.flatMap { $0.isEmpty ? nil : $0.brewDisplayText }
            previews.append(
                MethodStepPreview(
                    text: (stage?.message ?? "").brewDisplayText,
                    tip: tip,
                    addedGrams: added,
                    ingredient: ingredient,
                    waterTotal: waterTotal,
                    timing: timeline.entries[index]
                )
            )
        }

        return MethodPreview(
            steps: previews,
            timeline: timeline,
            water: UInt(max(0, draft.water.rounded()))
        )
    }

    /// A recipe at the draft's reference dose, for "Try it".
    func dryRunRecipe(for draft: MethodDraft, timerSpeedUp: UInt) -> Recipe {
        let dose = draft.referenceDose
        let stages = MethodDraftCompiler.evaluate(steps: instructionSteps(for: draft), dose: dose)
            .compactMap { $0 }
            .map { stage -> BrewStage in
                guard case .countdown(let seconds) = stage.requirement else { return stage }
                // Shorter timers, but the text keeps the real numbers.
                let shortened = max(1, (seconds + timerSpeedUp - 1) / max(timerSpeedUp, 1))
                return BrewStage(
                    action: stage.action,
                    requirement: .countdown(shortened),
                    startMethod: stage.startMethod,
                    passMethod: stage.passMethod,
                    message: stage.message,
                    details: stage.details
                )
            }

        var ingredients = [
            Ingredient(ingredientType: .coffee, amount: .init(amount: grams(dose.coffee), type: .gram)),
            Ingredient(ingredientType: .water, amount: .init(amount: grams(dose.water), type: .millilitre))
        ]
        if let ice = dose.ice, draft.addsIce {
            ingredients.append(Ingredient(ingredientType: .ice, amount: .init(amount: grams(ice), type: .gram)))
        }

        let name = draft.name.trimmingCharacters(in: .whitespaces)
        return Recipe(
            recipeProfile: RecipeProfile(
                name: name.isEmpty ? "Try it" : name,
                brewMethod: BrewMethod(
                    id: "try-it",
                    iconName: draft.iconName,
                    title: name.isEmpty ? "Try it" : name,
                    path: "",
                    isIcedBrew: draft.addsIce,
                    cupsCount: .unlimited,
                    ratios: [],
                    info: .init(title: "", body: "")
                )
            ),
            ingredients: ingredients,
            brewQueue: BrewQueue(stages: stages),
            cupsCount: 1,
            cupSize: dose.water + (draft.addsIce ? (dose.ice ?? 0) : 0)
        )
    }

    private func grams(_ value: Double) -> UInt {
        UInt(max(0, value.rounded()))
    }

    /// Whether the engine knows the running totals after this step: a put does, and so does a timed pause.
    static func setsRunningTotal(_ step: RecipeInstructionStep) -> Bool {
        switch step.instructionAction {
        case is PutInstructionAction:
            return true
        case let pause as PauseInstructionAction:
            if case .countdown? = pause.requirement { return true }
            return false
        default:
            return false
        }
    }

    /// Runs the step engine over `steps` at `dose`, the same way a recipe is built. Steps the engine can't read give `nil`.
    static func evaluate(steps: [RecipeInstructionStep], dose: ReferenceDose) -> [BrewStage?] {
        let coffee = Double(UInt(max(0, dose.coffee.rounded())))
        let water = Double(UInt(max(0, dose.water.rounded())))
        let ice = Double(UInt(max(0, (dose.ice ?? 0).rounded())))

        var context = InstructionActionContext(totalCoffee: coffee, totalWater: water)
        let input = RecipeInstructionInput(ingredients: ["coffee": coffee, "water": water, "ice": ice])

        return steps.map { step in
            step.instructionAction?.stage(for: input, in: &context)
        }
    }
}
