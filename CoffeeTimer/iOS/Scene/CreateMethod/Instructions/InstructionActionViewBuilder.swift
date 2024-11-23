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
                    title: "Ingredient",
                    placeholder: ""
                )
                .disabled(startMethodConstant)
                .grayscale(startMethodConstant ? 0.5 : 0.0)
            }
            
            if let amount {
                VStack {
                    TitledContent(title: "Amount (gram)") {
                        AlphanumericTextField(
                            text: amount,
                            placeholder: "0.2 * #current.water",
                            style: .plain
                        )
                    } infoContent: {
                        InformativeView(
                            title: "... Title TBD ... ",
                            description: informativeAmountDescription
                        )
                        .toAnyView()
                    }
                }
            }
        }
    }
}

#Preview {
    InstructionActionViewBuilder()
        .with(amount: .constant("23"))
        .build()
}

#Preview {
    RecipeInstructionActionView(item: .constant(.stubPut))
}

struct InformativeView: View {
    let title: String
    let description: String

    var body: some View {
        ScrollView {
            Spacer()

            Text(title)
                .lineLimit(nil)
                .font(.title3)

            Spacer()

            Text(description)
                .lineLimit(nil)
                .font(.body)

            Spacer()
        }
        .padding()
        .backgroundPrimary()
        .foregroundColor(Color("foregroundPrimary"))
        .ignoresSafeArea()
    }
}

// TODO: move
fileprivate let informativeAmountDescription: String = """
... TBD ...
- TODO: Write informative text explaining how this field can be used

e.g.:
You can use a constant amount or can express the amount relatively.

- Expressions are calculated per stage. Each keyword represent a value that is available in the context of the stage.
- Some values are constant (total amounts) and some others differs in each stage (eg. remainig water amount).

For example, followings would be accepted:
- 23 (23 gram of water)
- 0.4 * #coffee (40% of the total coffee amount)
- 0.6 * #current.water (60% of the water amount used so far)
- 0.7 * #remaining.water + 0.5 * #current.water (70% of the water amount left to pour)
- 245 * #current.coffee (yes - there is no limit to the multiplier (number), however, the outcome will be obviously bizarre)

However, followings would _not_ be accepted:
- 23asd: it contains alphanumeric values of 'asd'.
- 0.4 * coffee: keywords ('coffee' here) without '#' does not yield as keyword to the application.
- (0.6 * #current.water) * (0.5 * #remaining.coffee): multi-step expressions are not supported. Only a single expression can be used at a time.
- 0.7 / #remaining.water:

The known keywords you can use are:
#coffee: representing the total coffee amount
#water: representing the total water amount
#current.water: representing the water amount used/brewed so far
#current.coffee: repreesnting the coffee amount used so far
#remaining.water: representing the remaining water amount that still will be used
#remaining.coffee: representing the remaining coffee amont that will be used in later stages
"""
