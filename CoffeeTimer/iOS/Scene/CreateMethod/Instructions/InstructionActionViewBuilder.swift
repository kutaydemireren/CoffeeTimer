//
//  InstructionActionViewBuilder.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

private var interactionMethodInfo: InfoModel {
    .init(
        title: "Start Requirement Method",
        body: """
Flag to decide whether the queue should automatically run the current step (once the previous step is completed).
Only effective in the beginning of the steps.

Use 'User Interactive' if an active confirmation can be useful to begin the step.
"""
    )
}


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

    private var mainFactor: Binding<Double>?
    private var mainFactorOf: Binding<KeywordItem>?

    func with(mainFactor: Binding<Double>) -> Self {
        self.mainFactor = mainFactor
        return self
    }

    func with(mainFactorOf: Binding<KeywordItem>) -> Self {
        self.mainFactorOf = mainFactorOf
        return self
    }

    private var adjustmentFactor: Binding<Double>?
    private var adjustmentFactorOf: Binding<KeywordItem>?

    func with(adjustmentFactor: Binding<Double>) -> Self {
        self.adjustmentFactor = adjustmentFactor
        return self
    }

    func with(adjustmentFactorOf: Binding<KeywordItem>) -> Self {
        self.adjustmentFactorOf = adjustmentFactorOf
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
                    title: "Duration (seconds) [limit = 300 (5 min)]",
                    placeholder: "",
                    keyboardType: .number,
                    range: .init(minimum: 1, maximum: 300),
                    input: duration
                )
            }

            if let startMethod {
                TitledPicker(
                    selectedItem: startMethod,
                    allItems: .constant(InstructionInteractionMethodItem.allCases),
                    title: "Start Requirement Method",
                    placeholder: "",
                    infoModel: .init(
                        title: "Start Requirement Method",
                        body: """
Flag to decide whether the queue should automatically run the current step (once the previous step is completed).
Only effective at the beginning of each step.

Use 'User Interactive' if a confirmation can be useful to begin the step, letting the countdown begin.
"""
                    )
                )
                .disabled(startMethodConstant)
                .grayscale(startMethodConstant ? 0.5 : 0.0)
            }

            if let skipMethod {
                TitledPicker(
                    selectedItem: skipMethod,
                    allItems: .constant(InstructionInteractionMethodItem.allCases),
                    title: "Skip Step Method",
                    placeholder: "",
                    infoModel: .init(
                        title: "Skip Step Method",
                        body: """
Flag to decide whether the queue should automatically skip the current step (once the step is completed).
Only effective at the end of the each step.

Use 'User Interactive' if a confirmation can be useful to end the step, and to go to the next one.
"""
                    )
                )
                .disabled(skipMethodConstant)
                .grayscale(skipMethodConstant ? 0.5 : 0.0)
            }

            if let message {
                AlphanumericTextField(
                    text: message,
                    style: .titled("Message"),
                    placeholder: "Put all #total.coffee g of coffee to brewer",
                    infoModel: .init(
                        title: "Message",
                        body: """
Message is the main text displayed at the top, prominently.

Messages can contain the following keywords to display dynamic values within each step:
**#total.coffee**: Total coffee amount
**#total.water**: Total water amount 
**#current.amount**: The amount calculated for the current step
**#current.water**: Water used so far, the amount in the brewer
**#current.coffee**: Coffee used so far, the amount in the brewer
**#current.duration**: Duration set to requirement (0 if not set)
**#remaining.water**: Remaining water (total.water - current.water)
**#remaining.coffee**: Remaining coffee (total.coffee - current.coffee)
"""
                    )
                )
            }

            if let details {
                AlphanumericTextField(
                    text: details,
                    style: .titled("Secondary Message"),
                    placeholder: "Total water: #current.water ml",
                    infoModel: .init(
                        title: "Secondary Message",
                        body: """
Secondary message is the text displayed below the main text, less prominent but visible enough.

Secondary messages can contain the following keywords to display dynamic values within each step:
**#total.coffee**: Total coffee amount
**#total.water**: Total water amount 
**#current.amount**: The amount calculated for the current step
**#current.water**: Water used so far, the amount in the brewer
**#current.coffee**: Coffee used so far, the amount in the brewer
**#current.duration**: Duration set to requirement (0 if not set)
**#remaining.water**: Remaining water (total.water - current.water)
**#remaining.coffee**: Remaining coffee (total.coffee - current.coffee)
"""
                    )
                )
            }

            if let ingredient {
                TitledPicker(
                    selectedItem: ingredient,
                    allItems: .constant(IngredientTypeItem.allCases),
                    title: "Ingredient",
                    placeholder: ""
                )
            }

            if let mainFactor, let mainFactorOf, let adjustmentFactor, let adjustmentFactorOf {
                TitledContent(title: "Amount (gram)") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            NumericTextField(
                                title: "",
                                placeholder: "0.2",
                                range: .init(minimum: 0, maximum: 10),
                                input: mainFactor
                            )

                            Image(systemName: "xmark.app")
                                .foregroundColor(Color("foregroundPrimary").opacity(0.8))

                            Menu {
                                Picker(selection: mainFactorOf, label: EmptyView()) {
                                    ForEach([KeywordItem].stub) { ratio in
                                        Text(ratio.title)
                                    }
                                }
                            } label: {
                                Text(mainFactorOf.wrappedValue.title)
                                    .foregroundColor(Color("foregroundPrimary").opacity(0.8))
                                    .padding()
                                    .backgroundSecondary()
                            }
                        }

                        HStack {
                            Separator()
                            Image(systemName: "plus.circle")
                                .foregroundColor(Color("foregroundPrimary").opacity(0.8))
                            Separator()
                        }

                        Text("Not just right? Adjust the amount")
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color("foregroundPrimary"))
                            .font(.footnote)
                            .padding(.horizontal)

                        HStack(spacing: 4) {
                            VStack {
                                NumericTextField(
                                    title: "",
                                    placeholder: "0.2",
                                    range: .init(minimum: -10, maximum: 10),
                                    input: adjustmentFactor
                                )

                                Text("Leave empty for no addition")
                                    .foregroundColor(Color("foregroundPrimary").opacity(0.8))
                                    .font(.caption)
                            }

                            VStack {
                                Image(systemName: "xmark.square")
                                    .foregroundColor(Color("foregroundPrimary").opacity(0.8))
                                Text("")
                                    .font(.footnote)
                            }

                            Menu {
                                Picker(selection: adjustmentFactorOf, label: EmptyView()) {
                                    ForEach([KeywordItem].stub) { ratio in
                                        Text(ratio.title)
                                    }
                                }
                            } label: {
                                VStack {
                                    Text(adjustmentFactorOf.wrappedValue.title)
                                        .foregroundColor(Color("foregroundPrimary").opacity(0.8))
                                        .padding()
                                        .backgroundSecondary()
                                    Text("")
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
            }
        }
        .hideKeyboardOnTap()
    }
}

extension [KeywordItem] {
    static var stub: Self { // TODO: this is in use above! Replace it with a use case, whether it returns static element matters less.
        return [
            .init(keyword: "#total.coffee", title: "Total Coffee"),
            .init(keyword: "#total.water", title: "Total Water"),
            .init(keyword: "#total.ice", title: "Total Ice")
        ]
    }
}

#Preview {
    InstructionActionViewBuilder()
        .with(ingredient: .constant(.coffee))
        .with(mainFactor: .constant(0))
        .with(mainFactorOf: .constant(.totalCoffee))
        .with(adjustmentFactor: .constant(0))
        .with(adjustmentFactorOf: .constant(.totalCoffee))
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
