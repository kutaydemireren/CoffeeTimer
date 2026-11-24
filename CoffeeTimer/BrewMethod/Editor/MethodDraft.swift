//
//  MethodDraft.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation

/// What a step does, in the user's words. Saved in the step's optional `kind` field so the editor can show it again.
enum MethodStepKind: String, Codable, CaseIterable, Identifiable {
    case pour
    case wait
    case addCoffee
    case swirl
    case note
    case addIce
    case press
    case flip
    case remove

    var id: Self { self }

    /// Kinds shown first in the step palette.
    static let common: [MethodStepKind] = [.pour, .wait, .addCoffee, .swirl, .note]
    /// Kinds shown under "More".
    static let more: [MethodStepKind] = [.addIce, .press, .flip, .remove]

    var title: String {
        switch self {
        case .pour: return "Pour"
        case .wait: return "Wait"
        case .addCoffee: return "Add coffee"
        case .swirl: return "Swirl or stir"
        case .note: return "Note"
        case .addIce: return "Add ice"
        case .press: return "Press"
        case .flip: return "Flip"
        case .remove: return "Remove"
        }
    }

    var systemImage: String {
        switch self {
        case .pour: return "drop"
        case .wait: return "hourglass"
        case .addCoffee: return "mug"
        case .swirl: return "arrow.triangle.2.circlepath"
        case .note: return "text.bubble"
        case .addIce: return "snowflake"
        case .press: return "arrow.down.to.line"
        case .flip: return "arrow.up.arrow.down"
        case .remove: return "tray.and.arrow.up"
        }
    }

    /// The ingredient this kind puts in, if any.
    var ingredient: MethodIngredient? {
        switch self {
        case .pour: return .water
        case .addCoffee: return .coffee
        case .addIce: return .ice
        default: return nil
        }
    }

    var hasAmount: Bool { ingredient != nil }

    /// A Wait always has a timer.
    var needsTimer: Bool { self == .wait }

    /// Amount modes this kind offers. "The rest" is water only.
    var amountModes: [StepAmountMode] {
        switch self {
        case .pour: return [.upTo, .add, .rest]
        case .addCoffee, .addIce: return [.add]
        default: return []
        }
    }
}

enum MethodIngredient: String, Codable, Equatable {
    case coffee
    case water
    case ice
}

enum StepAmountMode: String, Codable, CaseIterable, Identifiable, Titled {
    case upTo
    case add
    case rest

    var id: Self { self }

    var title: String {
        switch self {
        case .upTo: return "Up to a total"
        case .add: return "Add an amount"
        case .rest: return "The rest"
        }
    }
}

/// An amount in grams, written for the method's reference dose.
enum StepAmount: Codable, Equatable {
    /// Pour until the running total reaches this many grams.
    case upTo(Double)
    /// Add this many grams.
    case add(Double)
    /// Whatever water is left.
    case rest

    var mode: StepAmountMode {
        switch self {
        case .upTo: return .upTo
        case .add: return .add
        case .rest: return .rest
        }
    }

    var grams: Double? {
        switch self {
        case .upTo(let grams), .add(let grams): return grams
        case .rest: return nil
        }
    }
}

enum StepTimeMode: String, Codable, CaseIterable, Identifiable, Titled {
    case none
    case takes
    case doneBy

    var id: Self { self }

    var title: String {
        switch self {
        case .none: return "No timer"
        case .takes: return "Takes"
        case .doneBy: return "Done by"
        }
    }
}

enum StepTime: Codable, Equatable {
    case none
    /// A countdown of this many seconds.
    case takes(UInt)
    /// Finished at this many seconds from the start of the brew.
    case doneBy(UInt)

    var mode: StepTimeMode {
        switch self {
        case .none: return .none
        case .takes: return .takes
        case .doneBy: return .doneBy
        }
    }

    var seconds: UInt? {
        switch self {
        case .none: return nil
        case .takes(let seconds), .doneBy(let seconds): return seconds
        }
    }
}

enum StepThen: String, Codable, CaseIterable, Identifiable, Titled {
    case carryOn
    case waitForTap

    var id: Self { self }

    var title: String {
        switch self {
        case .carryOn: return "Carry on by itself"
        case .waitForTap: return "Wait for my tap"
        }
    }
}

/// One step in the method editor.
struct MethodStep: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var kind: MethodStepKind
    var amount: StepAmount?
    var time: StepTime = .none
    var then: StepThen
    /// The brew-screen line in the user's own words, with tokens such as `#current.amount`. `nil` uses the generated line.
    var customText: String?
    /// The smaller line under the main one on the brew screen, with tokens. Empty for none.
    var tip: String = ""
    /// Whether the step's timer starts by itself. Kept from the stored step; new steps start by themselves.
    var startsByItself: Bool = true
    /// A stored step the editor fields cannot express. It is saved exactly as it was until the user edits the step.
    var legacy: LegacyStep?

    init(
        id: UUID = UUID(),
        kind: MethodStepKind,
        amount: StepAmount? = nil,
        time: StepTime = .none,
        then: StepThen? = nil,
        customText: String? = nil,
        tip: String = "",
        startsByItself: Bool = true,
        legacy: LegacyStep? = nil
    ) {
        self.id = id
        self.kind = kind
        self.amount = amount
        self.time = time
        self.then = then ?? MethodStep.defaultThen(for: kind, time: time)
        self.customText = customText
        self.tip = tip
        self.startsByItself = startsByItself
        self.legacy = legacy
    }

    /// A Wait carries on by itself; anything else waits for a tap.
    static func defaultThen(for kind: MethodStepKind, time: StepTime) -> StepThen {
        kind == .wait ? .carryOn : .waitForTap
    }

    /// A copy with a new id, for Duplicate.
    func duplicated() -> MethodStep {
        var copy = self
        copy.id = UUID()
        return copy
    }
}

/// A stored step kept verbatim, because the editor fields cannot express it.
struct LegacyStep: Codable, Equatable {
    /// The step's JSON, as stored.
    let json: Data

    init(step: RecipeInstructionStep) {
        json = (try? JSONEncoder().encode(step)) ?? Data()
    }

    init(json: Data) {
        self.json = json
    }

    var step: RecipeInstructionStep? {
        try? JSONDecoder().decode(RecipeInstructionStep.self, from: json)
    }
}

/// Where the draft came from.
enum MethodDraftOrigin: Codable, Equatable {
    case scratch
    /// "Make it mine" from this method's id.
    case copy(of: String)
    /// Editing the user's own method.
    case edit(BrewMethodSnapshot)
}

/// The parts of an edited method that the editor does not show but keeps on save.
struct BrewMethodSnapshot: Codable, Equatable {
    let id: String
    let path: String
    let cupsMinimum: Int
    let cupsMaximum: Int?
    let ratios: [CoffeeToWaterRatioDTO]
    let infoTitle: String
    let infoBody: String

    init(brewMethod: BrewMethod) {
        id = brewMethod.id
        path = brewMethod.path
        cupsMinimum = brewMethod.cupsCount.minimum
        cupsMaximum = brewMethod.cupsCount.maximum
        ratios = brewMethod.ratios.map { CoffeeToWaterRatioDTO(id: $0.id, value: $0.value, title: $0.title) }
        infoTitle = brewMethod.info.title
        infoBody = brewMethod.info.body
    }
}

/// The method being written in the editor. Codable so it can be kept as a draft.
struct MethodDraft: Codable, Equatable {
    var name: String
    var iconName: String
    var coffee: Double
    var water: Double
    /// Ice in grams; `nil` when the method adds no ice.
    var ice: Double?
    var steps: [MethodStep]
    var origin: MethodDraftOrigin

    static let defaultCoffee: Double = 15
    static let defaultWater: Double = 250
    static let kettleIcon = "recipe-profile-gooseneck-kettle"

    /// Icons offered on the method screen.
    static let icons = [
        "recipe-profile-gooseneck-kettle",
        "recipe-profile-v60",
        "recipe-profile-chemex",
        "recipe-profile-aeropress",
        "recipe-profile-french-press"
    ]

    static func scratch() -> MethodDraft {
        MethodDraft(
            name: "",
            iconName: kettleIcon,
            coffee: defaultCoffee,
            water: defaultWater,
            ice: nil,
            steps: [],
            origin: .scratch
        )
    }

    var referenceDose: ReferenceDose {
        ReferenceDose(coffee: coffee, water: water, ice: ice)
    }

    var addsIce: Bool {
        steps.contains { $0.kind == .addIce || $0.legacyIngredient == .ice }
    }

    var editedMethodId: String? {
        if case .edit(let snapshot) = origin { return snapshot.id }
        return nil
    }
}

extension MethodStep {
    /// The ingredient of a kept legacy `put` step.
    var legacyIngredient: MethodIngredient? {
        guard let put = legacy?.step?.instructionAction as? PutInstructionAction else { return nil }
        return put.ingredient.flatMap(MethodIngredient.init(rawValue:))
    }
}
