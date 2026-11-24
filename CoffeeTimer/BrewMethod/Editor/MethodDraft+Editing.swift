//
//  MethodDraft+Editing.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation

/// Why a draft can't be saved yet, in words shown to the user.
enum MethodValidationIssue: Equatable {
    case missingName
    case missingSteps
    case missingDose
    case missingIce
    case emptyNote(step: Int)
    case missingAmount(step: Int)
    case doneByTooEarly(step: Int, start: UInt)
    case timerTooLong(step: Int)

    var message: String {
        switch self {
        case .missingName:
            return "Add a name"
        case .missingSteps:
            return "Add at least one step"
        case .missingDose:
            return "Set the coffee and water it is written for"
        case .missingIce:
            return "Set the ice it is written for"
        case .emptyNote(let step):
            return "Write the note in step \(step)"
        case .missingAmount(let step):
            return "Set an amount in step \(step)"
        case .doneByTooEarly(let step, let start):
            return "Step \(step) starts at \(MethodTimeFormat.clock(start)), so \"Done by\" must be later"
        case .timerTooLong(let step):
            return "Timers go up to 60:00 (step \(step))"
        }
    }

    /// The step the issue is about, counted from 1.
    var stepNumber: Int? {
        switch self {
        case .emptyNote(let step), .missingAmount(let step), .doneByTooEarly(let step, _), .timerTooLong(let step):
            return step
        default:
            return nil
        }
    }
}

extension MethodDraft {
    /// Everything that stops the draft from being saved, most important first.
    var validationIssues: [MethodValidationIssue] {
        var issues: [MethodValidationIssue] = []
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(.missingName)
        }
        if steps.isEmpty {
            issues.append(.missingSteps)
        }
        if coffee <= 0 || water <= 0 {
            issues.append(.missingDose)
        }
        if steps.contains(where: { $0.kind == .addIce && $0.legacy == nil }), (ice ?? 0) <= 0 {
            issues.append(.missingIce)
        }

        let timeline = MethodTimeline(steps: steps)
        for (index, step) in steps.enumerated() where step.legacy == nil {
            let number = index + 1
            if step.kind == .note, (step.customText ?? "").trimmingCharacters(in: .whitespaces).isEmpty {
                issues.append(.emptyNote(step: number))
            }
            if step.kind.hasAmount, let grams = step.amount?.grams, grams <= 0 {
                issues.append(.missingAmount(step: number))
            }
            let entry = timeline.entries[index]
            if case .doneBy = step.time, !entry.isValid {
                issues.append(.doneByTooEarly(step: number, start: entry.start))
            }
            if let duration = entry.duration, duration > MethodTimeline.maximumSeconds {
                issues.append(.timerTooLong(step: number))
            }
        }
        return issues
    }

    /// The draft with new reference amounts. With `scaleSteps`, step amounts keep their share of the dose
    /// (rounded to the gram) and times stay the same. Without it, the grams stay as typed.
    func updatingDose(coffee newCoffee: Double, water newWater: Double, ice newIce: Double?, scaleSteps: Bool) -> MethodDraft {
        var draft = self
        draft.coffee = newCoffee
        draft.water = newWater
        draft.ice = newIce
        guard scaleSteps else { return draft }

        func factor(_ new: Double?, _ old: Double?) -> Double {
            guard let new, let old, old > 0 else { return 1 }
            return new / old
        }

        draft.steps = steps.map { step in
            guard step.legacy == nil, let ingredient = step.kind.ingredient, let amount = step.amount else { return step }
            let scale: Double
            switch ingredient {
            case .water: scale = factor(newWater, water)
            case .coffee: scale = factor(newCoffee, coffee)
            case .ice: scale = factor(newIce, ice)
            }
            var scaled = step
            switch amount {
            case .upTo(let grams): scaled.amount = .upTo((grams * scale).rounded())
            case .add(let grams): scaled.amount = .add((grams * scale).rounded())
            case .rest: break
            }
            return scaled
        }
        return draft
    }

    /// A new step of `kind` with sensible defaults for this draft, to insert at `index`.
    func newStep(kind: MethodStepKind, at index: Int) -> MethodStep {
        switch kind {
        case .pour:
            return MethodStep(kind: .pour, amount: .upTo(water.rounded()))
        case .wait:
            return MethodStep(kind: .wait, time: .takes(30))
        case .addCoffee:
            return MethodStep(kind: .addCoffee, amount: .add(coffee.rounded()))
        case .addIce:
            return MethodStep(kind: .addIce, amount: .add((ice ?? MethodDraft.defaultIce(forWater: water)).rounded()))
        case .note:
            return MethodStep(kind: .note, customText: "")
        case .swirl, .press, .flip, .remove:
            return MethodStep(kind: kind)
        }
    }

    /// Ice for a hot method that gets an Add ice step: today's 40% share of the total liquid.
    static func defaultIce(forWater water: Double) -> Double {
        (water * 2 / 3).rounded()
    }

    /// Sets the last pour to "The rest", the one-tap fix when the pours don't add up.
    func makingLastPourTheRest() -> MethodDraft {
        guard let index = steps.lastIndex(where: { $0.kind == .pour }) else { return self }
        var draft = self
        draft.steps[index].legacy = nil
        draft.steps[index].amount = .rest
        return draft
    }
}
