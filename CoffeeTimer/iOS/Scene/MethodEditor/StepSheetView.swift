//
//  StepSheetView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI

/// Edits one step: amount, time, what happens next, the brew-screen line and a tip.
/// Each kind shows only the fields it needs.
struct StepSheetView: View {
    @ObservedObject var viewModel: MethodEditorViewModel
    @Binding var step: MethodStep

    @Environment(\.dismiss) private var dismiss

    private var index: Int {
        viewModel.index(ofStep: step.id) ?? 0
    }

    private var preview: MethodStepPreview? {
        viewModel.preview.steps[safe: index]
    }

    private var timing: MethodTimeline.Entry? {
        viewModel.preview.timeline.entries[safe: index]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Step \(index + 1): \(step.kind.title)", systemImage: step.kind.systemImage)
                    .font(.title3)
                Spacer()
                Button("Done") { dismiss() }
                    .bold()
                    .foregroundStyle(Color("backgroundSecondary"))
            }
            .foregroundStyle(Color("foregroundPrimary"))
            .padding()

            ScrollView {
                VStack(spacing: 16) {
                    if step.legacy != nil {
                        legacyNotice
                    }

                    linePreview

                    if step.kind.hasAmount {
                        amountSection
                    }

                    timeSection

                    if step.time != .none {
                        thenSection
                    } else {
                        Text("Without a timer, the step waits for your tap.")
                            .font(.subheadline)
                            .foregroundStyle(Color("foregroundSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }

                    lineSection

                    AlphanumericTextField(
                        text: $step.tip,
                        style: .titled("Tip (optional)"),
                        placeholder: "Pour gently in circles"
                    )

                    actions
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .backgroundPrimary()
        .presentationDetents([.large])
    }

    // MARK: Sections

    private var legacyNotice: some View {
        HStack(alignment: .top) {
            Image(systemName: "info.circle")
            Text("This step is kept exactly as it was saved. Change anything here and it is saved in grams like the other steps.")
                .font(.subheadline)
        }
        .foregroundStyle(Color("foregroundPrimary"))
        .padding()
        .backgroundSecondary(opacity: 0.4)
    }

    /// What the brew screen will show, in the brew screen's own header style.
    private var linePreview: some View {
        VStack(spacing: 8) {
            StageHeaderView(
                header: StageHeader(
                    lightTitle: "It is time to",
                    title: (preview?.text).flatMap { $0.isEmpty ? nil : $0 } ?? "Write a note",
                    subtext: preview?.tip
                )
            )
            if let meta = metaText, !meta.isEmpty {
                Text(meta)
                    .font(.subheadline)
                    .foregroundStyle(Color("foregroundSecondary"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color("backgroundSecondary").opacity(0.8), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Brew screen preview")
    }

    private var metaText: String? {
        MethodStepRowView.metaLine(step: step, preview: preview)
    }

    private var amountSection: some View {
        VStack(spacing: 12) {
            if step.kind.amountModes.count > 1 {
                TitledPicker(
                    selectedItem: optional(amountModeBinding),
                    allItems: .constant(step.kind.amountModes),
                    title: "Amount",
                    placeholder: "Choose"
                )
            }

            TitledContent(title: step.kind.amountModes.count > 1 ? "Grams" : "Amount") {
                VStack(spacing: 12) {
                    switch step.amount {
                    case .rest?:
                        Text("Whatever water is left: \(preview?.addedGrams ?? 0) g")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    default:
                        HStack {
                            NumericTextField(
                                title: "",
                                placeholder: "grams",
                                keyboardType: .decimal,
                                range: .init(minimum: 0, maximum: 10000),
                                input: gramsBinding
                            )
                            Text(amountUnitText)
                        }
                        Text(amountHint)
                            .font(.subheadline)
                            .foregroundStyle(Color("foregroundSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private func optional<T>(_ binding: Binding<T>) -> Binding<T?> {
        Binding<T?>(
            get: { binding.wrappedValue },
            set: { if let newValue = $0 { binding.wrappedValue = newValue } }
        )
    }

    private var amountUnitText: String {
        switch step.kind {
        case .addCoffee: return "g coffee"
        case .addIce: return "g ice"
        default: return "g"
        }
    }

    private var amountHint: String {
        switch step.amount {
        case .upTo?:
            return "Pour until the scale shows this total. This pour adds \(preview?.addedGrams ?? 0) g."
        case .add?:
            if step.kind == .pour, let total = preview?.waterTotal {
                return "Adds this much. Water so far: \(total) g."
            }
            return "Adds this much."
        default:
            return ""
        }
    }

    private var timeSection: some View {
        VStack(spacing: 12) {
            TitledPicker(
                selectedItem: optional(timeModeBinding),
                allItems: .constant(availableTimeModes),
                title: "Time",
                placeholder: "Choose"
            )

            if step.time != .none {
                TitledContent(title: step.time.mode == .doneBy ? "Done by (m:ss from the start)" : "Takes (m:ss)") {
                    VStack(spacing: 12) {
                        NumericTextField(
                            title: "",
                            placeholder: "m:ss",
                            range: .init(minimum: 1, maximum: Int(MethodTimeline.maximumSeconds)),
                            format: .minutesSeconds,
                            input: secondsBinding
                        )
                        Text(timeHint)
                            .font(.subheadline)
                            .foregroundStyle(Color("foregroundSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var availableTimeModes: [StepTimeMode] {
        step.kind.needsTimer ? [.takes, .doneBy] : StepTimeMode.allCases
    }

    private var timeHint: String {
        let start = timing?.start ?? 0
        switch step.time {
        case .takes:
            return "Starts at \(MethodTimeFormat.clock(start)). Up to 60:00, typed as m:ss."
        case .doneBy:
            guard let timing, timing.isValid, let duration = timing.duration else {
                return "This step starts at \(MethodTimeFormat.clock(start)), so pick a later time."
            }
            return "Starts at \(MethodTimeFormat.clock(start)), so this is a \(MethodTimeFormat.short(duration)) timer. Steps that wait for a tap count as 0 s."
        case .none:
            return ""
        }
    }

    private var thenSection: some View {
        TitledPicker(
            selectedItem: optional($step.then),
            allItems: .constant(StepThen.allCases),
            title: "Then",
            placeholder: "Choose"
        )
    }

    private var lineSection: some View {
        VStack(spacing: 8) {
            AlphanumericTextField(
                text: lineBinding,
                style: .titled("Brew-screen line"),
                placeholder: step.kind == .note ? "Rinse the filter" : "Your own words"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(MethodStepText.insertablePlaceholders(for: step.kind), id: \.placeholder) { item in
                        Button {
                            lineBinding.wrappedValue += (lineBinding.wrappedValue.hasSuffix(" ") || lineBinding.wrappedValue.isEmpty ? "" : " ") + item.placeholder
                        } label: {
                            Text("+ \(item.title)")
                                .font(.footnote)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .backgroundSecondary(opacity: 0.4)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color("foregroundPrimary"))
                    }
                }
            }

            HStack {
                Text("Placeholders like {amount} show live numbers on the brew screen.")
                    .font(.footnote)
                    .foregroundStyle(Color("foregroundSecondary"))
                Spacer()
                if step.customText != nil, step.kind != .note {
                    Button("Use suggested") {
                        step.customText = nil
                    }
                    .font(.footnote.bold())
                    .foregroundStyle(Color("foregroundPrimary"))
                }
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.duplicate(stepID: step.id)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .backgroundSecondary(opacity: 0.6)
            }

            Button(role: .destructive) {
                viewModel.delete(stepID: step.id)
            } label: {
                Label("Delete", systemImage: "trash")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .backgroundSecondary(opacity: 0.6)
            }
        }
        .foregroundStyle(Color("foregroundPrimary"))
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    // MARK: Bindings

    private var amountModeBinding: Binding<StepAmountMode> {
        Binding(
            get: { step.amount?.mode ?? .add },
            set: { mode in
                let grams = step.amount?.grams ?? Double(preview?.addedGrams ?? 0)
                switch mode {
                case .upTo:
                    // Keep the same pour: the new total is what was poured so far after this step.
                    step.amount = .upTo(step.amount?.mode == .add ? Double(preview?.waterTotal ?? 0) : grams)
                case .add:
                    step.amount = .add(Double(preview?.addedGrams ?? UInt(max(0, grams))))
                case .rest:
                    step.amount = .rest
                }
            }
        )
    }

    private var gramsBinding: Binding<Double> {
        Binding(
            get: { step.amount?.grams ?? 0 },
            set: { grams in
                switch step.amount {
                case .upTo?: step.amount = .upTo(grams)
                case .rest?: break
                default: step.amount = .add(grams)
                }
            }
        )
    }

    private var timeModeBinding: Binding<StepTimeMode> {
        Binding(
            get: { step.time.mode },
            set: { mode in
                let start = timing?.start ?? 0
                let duration = timing?.duration ?? step.time.seconds ?? 30
                switch mode {
                case .none:
                    step.time = .none
                case .takes:
                    step.time = .takes(min(max(duration, 1), MethodTimeline.maximumSeconds))
                case .doneBy:
                    step.time = .doneBy(min(start + max(duration, 1), MethodTimeline.maximumSeconds))
                }
            }
        )
    }

    private var secondsBinding: Binding<Double> {
        Binding(
            get: { Double(step.time.seconds ?? 0) },
            set: { seconds in
                let value = UInt(max(1, min(seconds, Double(MethodTimeline.maximumSeconds))))
                switch step.time {
                case .takes: step.time = .takes(value)
                case .doneBy: step.time = .doneBy(value)
                case .none: break
                }
            }
        )
    }

    /// The line with placeholders such as {amount}; stored with engine tokens.
    private var lineBinding: Binding<String> {
        Binding(
            get: {
                let text = step.customText ?? MethodStepText.generated(for: step, duration: timing?.duration)
                return MethodStepText.placeholders(fromTokens: text)
            },
            set: { newValue in
                let generated = MethodStepText.placeholders(
                    fromTokens: MethodStepText.generated(for: step, duration: timing?.duration)
                )
                if newValue == generated && step.kind != .note {
                    step.customText = nil
                } else {
                    step.customText = MethodStepText.tokens(fromPlaceholders: newValue)
                }
            }
        )
    }
}
