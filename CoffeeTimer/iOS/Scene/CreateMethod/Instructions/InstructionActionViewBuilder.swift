//
//  InstructionActionViewBuilder.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

final class InstructionActionViewBuilder {
    private var requirementConstant: Bool = false
    private var requirement: Binding<InstructionRequirementItem?>?

    func with(requirement: InstructionRequirementItem) -> Self {
        self.requirement = .constant(requirement)
        requirementConstant = true
        return self
    }

    func with(requirement: Binding<InstructionRequirementItem?>) -> Self {
        self.requirement = requirement
        return self
    }

    private var duration: Binding<Double>?

    func with(duration: Binding<Double>) -> Self {
        self.duration = duration
        return self
    }

    private var startMethodConstant: Bool = false
    private var startMethod: Binding<InstructionInteractionMethodItem?>?

    func with(startMethod: InstructionInteractionMethodItem) -> Self {
        self.startMethod = .constant(startMethod)
        startMethodConstant = true
        return self
    }

    func with(startMethod: Binding<InstructionInteractionMethodItem?>?) -> Self {
        self.startMethod = startMethod
        return self
    }

    private var skipMethodConstant: Bool = false
    private var skipMethod: Binding<InstructionInteractionMethodItem?>?

    func with(skipMethod: InstructionInteractionMethodItem) -> Self {
        self.skipMethod = .constant(skipMethod)
        skipMethodConstant = true
        return self
    }

    func with(skipMethod: Binding<InstructionInteractionMethodItem?>?) -> Self {
        self.skipMethod = skipMethod
        return self
    }

    private var message: Binding<String>?

    func with(message: Binding<String>) -> Self {
        self.message = message
        return self
    }

    private var details: Binding<String>?

    func with(details: Binding<String>) -> Self {
        self.details = details
        return self
    }

    private var ingredient: Binding<IngredientTypeItem?>?

    func with(ingredient: Binding<IngredientTypeItem?>) -> Self {
        self.ingredient = ingredient
        return self
    }

    private var amount: Binding<String>?

    func with(amount: Binding<String>) -> Self {
        self.amount = amount
        return self
    }

    @ViewBuilder
    func build() -> some View {
        ScrollView {
            VStack {
                if let requirement {
                    TitledPicker(
                        selectedItem: requirement,
                        allItems: .constant(InstructionRequirementItem.allCases),
                        title: "Requirement",
                        placeholder: ""
                    )
                    .disabled(requirementConstant)
                    .grayscale(requirementConstant ? 0.5 : 0.0)
                }

                if let duration, requirement?.wrappedValue == .countdown {
                    NumericTextField(
                        title: "Duration (in seconds - limited to 300 seconds)",
                        placeholder: "",
                        keyboardType: .number,
                        range: .init(minimum: 1, maximum: 5 * 60),
                        input: duration
                    )
                }

                if let startMethod {
                    TitledPicker(
                        selectedItem: startMethod,
                        allItems: .constant(InstructionInteractionMethodItem.allCases),
                        title: "Start Requirement Method",
                        placeholder: ""
                    )
                    .disabled(startMethodConstant)
                    .grayscale(startMethodConstant ? 0.5 : 0.0)
                }

                if let skipMethod {
                    TitledPicker(
                        selectedItem: skipMethod,
                        allItems: .constant(InstructionInteractionMethodItem.allCases),
                        title: "Skip Step Method",
                        placeholder: ""
                    )
                    .disabled(skipMethodConstant)
                    .grayscale(skipMethodConstant ? 0.5 : 0.0)
                }

                if let message {
                    AlphanumericTextField(
                        title: "Message",
                        placeholder: "",
                        text: message
                    )
                }

                if let details {
                    AlphanumericTextField(
                        title: "Secondary Message (optional)",
                        placeholder: "",
                        text: details
                    )
                }

                if let ingredient {
                    TitledPicker(
                        selectedItem: ingredient,
                        allItems: .constant(IngredientTypeItem.allCases),
                        title: "Start Requirement Method",
                        placeholder: ""
                    )
                    .disabled(startMethodConstant)
                    .grayscale(startMethodConstant ? 0.5 : 0.0)
                }

                if let amount {
                    AlphanumericTextField(
                        title: "Amount (gram) (23 | 0.4 * #coffee | 0.6 * #current.water | 0.7 * #remaining.water)",
                        placeholder: "0.2 * #current.water",
                        text: amount
                    )
                }
            }
        }
    }
}
