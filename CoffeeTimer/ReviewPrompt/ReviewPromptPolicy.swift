//
//  ReviewPromptPolicy.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 19/11/2026.
//

import Foundation

/// A positive moment the app reports to the review prompt policy.
/// See `docs/review-prompt.md` for why these moments were chosen.
enum ReviewPromptEvent: Equatable {
    /// The user followed every step of a brew to the end.
    case brewCompleted(duration: TimeInterval)
    /// The user tapped "End" during a brew.
    /// `completedSteps` is the number of steps before the one on screen (its 0-based index).
    case brewEnded(duration: TimeInterval, completedSteps: Int, totalSteps: Int)
    case customMethodCreated
    case recipeCreated
    case recipeAmountsEdited
}

/// The moment a review request is made at. The raw value is sent as the `trigger` analytics parameter.
enum ReviewPromptTrigger: String, Equatable {
    case brewCompleted = "brew_completed"
    case brewEnded = "brew_ended"
    case customMethodCreated = "method_created"
    case recipeCreated = "recipe_created"
    case recipeAmountsEdited = "amounts_edited"
}

enum BrewSessionRules {
    /// Brews shorter than this are treated as a misclick or a quick look:
    /// ending one does not show the post-brew screen and does not count towards a review request.
    static let meaningfulDuration: TimeInterval = 60

    /// A brew is past halfway when at least half of its steps are done:
    /// the step on screen has a 0-based index of at least `ceil(totalSteps / 2)`.
    /// For a 15-step recipe that is the 9th step or later.
    static func isPastHalfway(completedSteps: Int, totalSteps: Int) -> Bool {
        totalSteps > 0 && completedSteps * 2 >= totalSteps
    }
}

/// Records positive moments and decides when the app may ask the system for a review.
///
/// Usage:
/// 1. Call `record(_:)` when a positive moment happens.
/// 2. At a settled screen, call `takePendingTrigger()`. A non-nil result means the screen may request a review.
/// 3. Call `didRequestReview()` right when the system review prompt is requested.
protocol ReviewPromptPolicy: AnyObject {
    func record(_ event: ReviewPromptEvent)
    /// Returns the trigger waiting to be shown, if the global rules allow a request now, and clears it.
    func takePendingTrigger() -> ReviewPromptTrigger?
    func didRequestReview()
}

struct ReviewPromptState: Codable, Equatable {
    var meaningfulBrewCount = 0
    var recipesCreatedCount = 0
    var customMethodsCreatedCount = 0
    var amountsEditedCount = 0
    var lastRequestDate: Date?
    var lastRequestAppVersion: String?
}

final class ReviewPromptPolicyImp: ReviewPromptPolicy {
    static let shared = ReviewPromptPolicyImp()

    enum Rules {
        /// A completed brew is a strong signal, so it asks from the user's 1st meaningful brew on.
        static let meaningfulBrewsForCompletedBrew = 1
        /// An End after at least half of the steps is close to a full brew, so it asks from the 1st meaningful brew on.
        static let meaningfulBrewsForEndedBrewPastHalfway = 1
        /// An End before halfway is a weak signal (it may be an early quitter), so it waits for the 3rd meaningful brew.
        static let meaningfulBrewsForEndedBrew = 3
        static let customMethodsCreated = 1
        /// The first recipe is often a trial.
        static let recipesCreated = 2
        static let amountsEdited = 2
        /// App-side gap between two requests, on top of Apple's own limit of 3 prompts in 365 days.
        static let cooldown: TimeInterval = 30 * 24 * 60 * 60
    }

    static let storageKey = "reviewPromptState"

    private var pendingTrigger: ReviewPromptTrigger?

    private let storage: Storage
    private let dateProvider: DateProvider
    private let appVersion: String

    init(
        storage: Storage = StorageImp(userDefaults: .standard),
        dateProvider: DateProvider = DateProviderImp(),
        appVersion: String = Bundle.main.appVersion
    ) {
        self.storage = storage
        self.dateProvider = dateProvider
        self.appVersion = appVersion
    }

    func record(_ event: ReviewPromptEvent) {
        var state = loadState()
        var trigger: ReviewPromptTrigger?

        switch event {
        case .brewCompleted(let duration):
            guard duration >= BrewSessionRules.meaningfulDuration else { return }
            state.meaningfulBrewCount += 1
            if state.meaningfulBrewCount >= Rules.meaningfulBrewsForCompletedBrew {
                trigger = .brewCompleted
            }
        case .brewEnded(let duration, let completedSteps, let totalSteps):
            guard duration >= BrewSessionRules.meaningfulDuration else { return }
            state.meaningfulBrewCount += 1
            let threshold = BrewSessionRules.isPastHalfway(completedSteps: completedSteps, totalSteps: totalSteps)
                ? Rules.meaningfulBrewsForEndedBrewPastHalfway
                : Rules.meaningfulBrewsForEndedBrew
            if state.meaningfulBrewCount >= threshold {
                trigger = .brewEnded
            }
        case .customMethodCreated:
            state.customMethodsCreatedCount += 1
            if state.customMethodsCreatedCount >= Rules.customMethodsCreated {
                trigger = .customMethodCreated
            }
        case .recipeCreated:
            state.recipesCreatedCount += 1
            if state.recipesCreatedCount >= Rules.recipesCreated {
                trigger = .recipeCreated
            }
        case .recipeAmountsEdited:
            state.amountsEditedCount += 1
            if state.amountsEditedCount >= Rules.amountsEdited {
                trigger = .recipeAmountsEdited
            }
        }

        save(state)

        if let trigger {
            pendingTrigger = trigger
        }
    }

    func takePendingTrigger() -> ReviewPromptTrigger? {
        defer { pendingTrigger = nil }
        guard let pendingTrigger, canRequestNow(state: loadState()) else {
            return nil
        }
        return pendingTrigger
    }

    func didRequestReview() {
        var state = loadState()
        state.lastRequestDate = dateProvider.now
        state.lastRequestAppVersion = appVersion
        save(state)
    }

    private func canRequestNow(state: ReviewPromptState) -> Bool {
        if state.lastRequestAppVersion == appVersion {
            return false
        }
        if let lastRequestDate = state.lastRequestDate,
           dateProvider.now.timeIntervalSince(lastRequestDate) < Rules.cooldown {
            return false
        }
        return true
    }

    private func loadState() -> ReviewPromptState {
        storage.load(forKey: Self.storageKey) ?? ReviewPromptState()
    }

    private func save(_ state: ReviewPromptState) {
        storage.save(state, forKey: Self.storageKey)
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
}
