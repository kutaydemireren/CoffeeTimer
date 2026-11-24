//
//  MethodStepRowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI

/// A step row, laid out like `RecipeRowView`: the brew-screen line, a quieter meta line, and the water poured so far on the right.
struct MethodStepRowView: View {
    let number: Int
    let step: MethodStep
    let preview: MethodStepPreview?
    var isHighlighted = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: step.kind.systemImage)
                .frame(width: 24)
                .foregroundStyle(Color("foregroundPrimary"))

            VStack(alignment: .leading, spacing: 4) {
                Text(mainLine)
                    .foregroundStyle(Color("foregroundPrimary"))
                    .bold()
                    .lineLimit(2)

                if !metaLine.isEmpty {
                    Text(metaLine)
                        .font(.subheadline)
                        .foregroundStyle(Color("foregroundSecondary"))
                }
            }

            Spacer(minLength: 8)

            if let preview, preview.waterTotal > 0 {
                Text("\(preview.waterTotal) g")
                    .font(.subheadline)
                    .foregroundStyle(Color("foregroundSecondary"))
                    .accessibilityLabel("\(preview.waterTotal) grams of water so far")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            BackgroundSecondary(opacity: isHighlighted ? 0.9 : 0.5)
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Step \(number). Opens the step")
    }

    private var mainLine: String {
        let text = preview?.text ?? ""
        if text.isEmpty {
            return step.kind == .note ? "Write a note" : step.kind.title
        }
        return text
    }

    /// For example "+120 g · done by 1:15 (30 s)".
    var metaLine: String {
        MethodStepRowView.metaLine(step: step, preview: preview)
    }

    static func metaLine(step: MethodStep, preview: MethodStepPreview?) -> String {
        var parts: [String] = []

        if let added = preview?.addedGrams {
            switch preview?.ingredient {
            case .coffee?: parts.append("+\(added) g coffee")
            case .ice?: parts.append("+\(added) g ice")
            default: parts.append("+\(added) g")
            }
        }

        if let timing = preview?.timing {
            if step.legacy == nil, case .doneBy(let doneBy) = step.time {
                if timing.isValid, let duration = timing.duration {
                    parts.append("done by \(MethodTimeFormat.clock(doneBy)) (\(MethodTimeFormat.short(duration)))")
                } else {
                    parts.append("done by \(MethodTimeFormat.clock(doneBy)), before it starts")
                }
            } else if let duration = timing.duration {
                parts.append("\(MethodTimeFormat.short(duration)) \(timerNoun(for: step.kind))")
            }

            if timing.duration != nil, step.then == .waitForTap {
                parts.append("then waits for your tap")
            }
        }

        if step.legacy != nil {
            parts.append("kept as saved")
        }

        return parts.joined(separator: " \u{00B7} ")
    }

    private static func timerNoun(for kind: MethodStepKind) -> String {
        switch kind {
        case .pour: return "pour"
        case .wait: return "wait"
        default: return "timer"
        }
    }
}

/// Totals and estimated end time. Turns into a warning with a one-tap fix when the pours don't add up.
struct MethodFooterView: View {
    let preview: MethodPreview
    let hasPour: Bool
    let lastPourIsRest: Bool
    var makeLastPourTheRest: () -> Void
    var matchWaterToPoured: () -> Void
    var addPour: () -> Void

    @State private var pulse = false

    private var isWarning: Bool {
        !preview.waterMatches
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if isWarning {
                    Image(systemName: "exclamationmark.triangle")
                }
                Text("\(preview.pouredWater) of \(preview.water) g water poured")
                    .bold(isWarning)
                Spacer()
            }

            if preview.timeline.total > 0 {
                Text("Ends around \(MethodTimeFormat.clock(preview.timeline.total))")
            } else {
                Text("No timers yet")
            }

            if isWarning, let fix {
                Button(action: fix.action) {
                    Text(fix.title)
                        .bold()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .foregroundStyle(Color("foregroundPrimary"))
                        .backgroundSecondary()
                }
                .buttonStyle(.plain)
            }
        }
        .font(.subheadline)
        .foregroundStyle(isWarning ? Color("foregroundPrimary") : Color("foregroundSecondary"))
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BackgroundSecondary(opacity: isWarning ? 0.8 : 0.4))
        .highlightAnimation(isAnimating: $pulse)
        .onChange(of: isWarning) { _, newValue in
            guard newValue else { return }
            pulse = true
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(600))
                pulse = false
            }
        }
    }

    private var fix: (title: String, action: () -> Void)? {
        guard hasPour else {
            return ("Add a pour", addPour)
        }
        if !lastPourIsRest {
            return ("Make the last pour the rest", makeLastPourTheRest)
        }
        if preview.pouredWater > preview.water {
            return ("Write it for \(preview.pouredWater) g water", matchWaterToPoured)
        }
        return nil
    }
}
