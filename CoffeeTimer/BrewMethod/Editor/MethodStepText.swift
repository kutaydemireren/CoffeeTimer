//
//  MethodStepText.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation

/// Times as the method editor shows them.
enum MethodTimeFormat {
    /// "1:15", "0:30", "60:00".
    static func clock(_ seconds: UInt) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    /// "30 s" under a minute, "1:30" from a minute on.
    static func short(_ seconds: UInt) -> String {
        seconds < 60 ? "\(seconds) s" : clock(seconds)
    }

    /// Reads "1:15" or "75" as seconds. Partial input such as "1:" reads as whole minutes.
    static func parse(_ text: String) -> UInt? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let parts = trimmed.split(separator: ":", omittingEmptySubsequences: false)
        switch parts.count {
        case 1:
            return UInt(parts[0])
        case 2:
            guard let minutes = UInt(parts[0].isEmpty ? "0" : parts[0]) else { return nil }
            let secondsText = parts[1]
            guard secondsText.count <= 2 else { return nil }
            let seconds = secondsText.isEmpty ? 0 : (UInt(secondsText) ?? 60)
            guard seconds < 60 else { return nil }
            return minutes * 60 + seconds
        default:
            return nil
        }
    }
}

/// Builds the brew-screen line for a step, and moves between engine tokens and the placeholders users edit.
enum MethodStepText {
    /// Placeholders users see and type, and the engine tokens they stand for.
    static let placeholders: [(placeholder: String, token: String, title: String)] = [
        ("{amount}", InstructionKeyword.currentAmount.keyword, "This step's grams"),
        ("{total}", InstructionKeyword.currentWater.keyword, "Water so far"),
        ("{water left}", InstructionKeyword.remainingWater.keyword, "Water left"),
        ("{water}", InstructionKeyword.totalWater.keyword, "All water"),
        ("{coffee so far}", InstructionKeyword.currentCoffee.keyword, "Coffee so far"),
        ("{coffee left}", InstructionKeyword.remainingCoffee.keyword, "Coffee left"),
        ("{coffee}", InstructionKeyword.totalCoffee.keyword, "All coffee"),
        ("{time}", InstructionKeyword.currentDuration.keyword, "Wait time")
    ]

    /// Placeholders offered as insert buttons in the step sheet.
    static func insertablePlaceholders(for kind: MethodStepKind) -> [(placeholder: String, title: String)] {
        var result: [(String, String)] = []
        if kind.hasAmount { result.append(("{amount}", "This step's grams")) }
        if kind == .pour { result.append(("{total}", "Water so far")) }
        if kind == .wait { result.append(("{time}", "Wait time")) }
        result.append(("{water}", "All water"))
        result.append(("{coffee}", "All coffee"))
        return result
    }

    /// "Pour up to {total} g" → "Pour up to #current.water g".
    static func tokens(fromPlaceholders text: String) -> String {
        placeholders.reduce(text) { $0.replacingOccurrences(of: $1.placeholder, with: $1.token) }
    }

    /// "Pour up to #current.water g" → "Pour up to {total} g".
    static func placeholders(fromTokens text: String) -> String {
        // Longer tokens first, so "#current.water" is not cut by a shorter match.
        placeholders
            .sorted { $0.token.count > $1.token.count }
            .reduce(text) { $0.replacingOccurrences(of: $1.token, with: $1.placeholder) }
    }

    /// The line the editor writes for a step when the user has not rewritten it, with tokens so numbers stay live.
    static func generated(for step: MethodStep, duration: UInt?) -> String {
        switch step.kind {
        case .pour:
            switch step.amount {
            case .upTo?: return "Pour up to #current.water g"
            case .rest?: return "Pour the rest, #current.amount g"
            case .add?, nil: return "Pour #current.amount g"
            }
        case .wait:
            guard let duration, duration > 0 else { return "Wait" }
            return "Wait \(MethodTimeFormat.short(duration))"
        case .addCoffee:
            return "Add #current.amount g of coffee"
        case .addIce:
            return "Add #current.amount g of ice"
        case .swirl:
            return "Swirl or stir"
        case .note:
            return ""
        case .press:
            return "Press"
        case .flip:
            return "Flip"
        case .remove:
            return "Remove the brewer"
        }
    }

    /// The line saved as the step's message: the user's own words, or the generated line.
    static func message(for step: MethodStep, duration: UInt?) -> String {
        if let customText = step.customText, !customText.trimmingCharacters(in: .whitespaces).isEmpty {
            return customText
        }
        return generated(for: step, duration: duration)
    }
}
