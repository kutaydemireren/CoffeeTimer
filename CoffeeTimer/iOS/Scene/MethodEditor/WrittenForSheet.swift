//
//  WrittenForSheet.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI

/// Edits the amounts a method is written for, built like `EditRecipeAmountsView`.
/// When steps have amounts, Save asks whether to scale them.
struct WrittenForSheet: View {
    @ObservedObject var viewModel: MethodEditorViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var coffee: Double = 0
    @State private var water: Double = 0
    @State private var ice: Double = 0
    @State private var isScalePromptPresented = false

    private var showsIce: Bool {
        viewModel.draft.addsIce
    }

    private var hasChanged: Bool {
        coffee != viewModel.draft.coffee
            || water != viewModel.draft.water
            || (showsIce && ice != (viewModel.draft.ice ?? 0))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Written for")
                .font(.title3)
                .foregroundStyle(Color("foregroundPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.top, 32)
                .padding(.bottom, 8)

            ScrollView {
                VStack {
                    NumericTextField(
                        title: "Coffee (g)",
                        placeholder: "15",
                        keyboardType: .decimal,
                        range: .init(minimum: 1, maximum: 1000),
                        input: $coffee
                    )

                    NumericTextField(
                        title: "Water (g)",
                        placeholder: "250",
                        keyboardType: .decimal,
                        range: .init(minimum: 1, maximum: 10000),
                        input: $water
                    )

                    if showsIce {
                        NumericTextField(
                            title: "Ice (g)",
                            placeholder: "100",
                            keyboardType: .decimal,
                            range: .init(minimum: 1, maximum: 10000),
                            input: $ice
                        )
                    }

                    if coffee > 0, water > 0 {
                        Text("Ratio \(CoffeeToWaterRatio.label(for: water / coffee))")
                            .font(.subheadline)
                            .foregroundStyle(Color("foregroundSecondary"))
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 32)
            }

            footer
        }
        .ignoresSafeArea(.keyboard)
        .backgroundPrimary()
        .hideKeyboardOnTap()
        .onAppear {
            coffee = viewModel.draft.coffee
            water = viewModel.draft.water
            ice = viewModel.draft.ice ?? MethodDraft.defaultIce(forWater: viewModel.draft.water)
        }
        .confirmationDialog("Scale the steps too?", isPresented: $isScalePromptPresented, titleVisibility: .visible) {
            Button("Scale the steps") { apply(scaleSteps: true) }
            Button("Keep step amounts") { apply(scaleSteps: false) }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Scaling changes each step's grams to match. Times stay the same.")
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .bold()
            }
            .padding()
            .foregroundStyle(Color("foregroundPrimary").opacity(0.8))

            Spacer()

            Button {
                guard hasChanged else {
                    dismiss()
                    return
                }
                if viewModel.hasScalableSteps {
                    isScalePromptPresented = true
                } else {
                    apply(scaleSteps: false)
                }
            } label: {
                Text("Save")
                    .bold()
            }
            .padding()
            .foregroundStyle(Color("foregroundPrimary"))
            .backgroundSecondary()
            .shadow(color: .blue.opacity(0.2), radius: 8, x: -2, y: -2)
            .disabled(coffee <= 0 || water <= 0)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private func apply(scaleSteps: Bool) {
        viewModel.updateDose(
            coffee: coffee,
            water: water,
            ice: showsIce ? ice : viewModel.draft.ice,
            scaleSteps: scaleSteps
        )
        dismiss()
    }
}
