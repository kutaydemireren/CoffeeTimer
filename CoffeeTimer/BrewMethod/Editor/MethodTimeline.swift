//
//  MethodTimeline.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation

/// The planned timeline of a method: when each step starts and how long its countdown runs.
///
/// The brew runs on countdowns only. "Done by 1:15" becomes a countdown from the step's planned start.
/// Steps without a timer wait for a tap and count as 0 s.
struct MethodTimeline: Equatable {
    struct Entry: Equatable {
        /// Seconds from the start of the brew when the step starts.
        let start: UInt
        /// The step's countdown, `nil` without a timer or when "Done by" is not after the start.
        let duration: UInt?
        /// `false` when "Done by" is not after the step's start.
        let isValid: Bool

        var end: UInt { start + (duration ?? 0) }
    }

    /// Longest countdown the editor accepts: 60 minutes.
    static let maximumSeconds: UInt = 3600

    let entries: [Entry]

    /// Estimated end time in seconds.
    var total: UInt { entries.last?.end ?? 0 }

    init(steps: [MethodStep]) {
        var start: UInt = 0
        var entries: [Entry] = []
        for step in steps {
            let entry = MethodTimeline.entry(for: step, start: start)
            entries.append(entry)
            start = entry.end
        }
        self.entries = entries
    }

    private static func entry(for step: MethodStep, start: UInt) -> Entry {
        if let legacyStep = step.legacy?.step {
            if case .countdown(let seconds)? = legacyStep.instructionAction?.requirement {
                return Entry(start: start, duration: seconds, isValid: true)
            }
            return Entry(start: start, duration: nil, isValid: true)
        }

        switch step.time {
        case .none:
            return Entry(start: start, duration: nil, isValid: true)
        case .takes(let seconds):
            return Entry(start: start, duration: seconds > 0 ? seconds : nil, isValid: seconds > 0)
        case .doneBy(let doneBy):
            guard doneBy > start else {
                return Entry(start: start, duration: nil, isValid: false)
            }
            return Entry(start: start, duration: doneBy - start, isValid: true)
        }
    }
}
