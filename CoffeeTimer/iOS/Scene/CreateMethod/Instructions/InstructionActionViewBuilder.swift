//
//  InstructionActionViewBuilder.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 22/07/2024.
//

import SwiftUI

private var startMethodInfo: InfoModel {
    .init(
        title: "Start Requirement Method",
        body: """
Flag to decide whether the queue should automatically run the current step (once the previous step is completed).
Only effective at the beginning of each step.

Use 'User Interactive' if a confirmation can be useful to begin the step, letting the countdown begin.
"""
    )
}

private var skipMethodInfo: InfoModel {
    .init(
        title: "Skip Step Method",
        body: """
Flag to decide whether the queue should automatically skip the current step (once the step is completed).
Only effective at the end of the each step.

Use 'User Interactive' if a confirmation can be useful to end the step, and to go to the next one.
"""
    )
}

private var messageInfo: InfoModel {
    .init(
        title: "Message",
        body: """
Message is the main text displayed at the top, prominently.

It can contain the following keywords to display dynamic values within each step:
\t- **#current.amount** → Step-specific amount, dynamically calculated for the current instruction.
\t- **#current.duration** → Duration for the current step (0 if not set)
\t- **#current.coffee** → Amount of coffee added so far.
\t- **#current.water** → Amount of water added so far.
\t- **#total.coffee** → Total coffee planned for the brew.
\t- **#total.water** → Total water planned for the brew.
\t- **#remaining.coffee** → Remaining coffee to be added (*total.coffee - current.coffee*).
\t- **#remaining.water** → Remaining water to be added (*total.water - current.water*).
"""
    )
}

private var secondaryMessageInfo: InfoModel {
    .init(
        title: "Secondary Message",
        body: """
Secondary message is the text displayed below the main text, less prominent but visible enough.

It can contain the following keywords to display dynamic values within each step:
\t- **#current.amount** → Step-specific amount, dynamically calculated for the current instruction.
\t- **#current.duration** → Duration for the current step (0 if not set)
\t- **#current.coffee** → Amount of coffee added so far.
\t- **#current.water** → Amount of water added so far.
\t- **#total.coffee** → Total coffee planned for the brew.
\t- **#total.water** → Total water planned for the brew.
\t- **#remaining.coffee** → Remaining coffee to be added (*total.coffee - current.coffee*).
\t- **#remaining.water** → Remaining water to be added (*total.water - current.water*).
"""
    )
}

private var amountInfo: InfoModel {
    .init(
        title: "Amount Configuration",
        body: """
The amount field determines the quantity for each brewing step using two factors:  

1. **Main Factor:**
   - Defines the base quantity. It must be defined.
   - Choose a **keyword** to indicate what the factor applies to (e.g., *Current Water*, *Remaining Coffee*).
   - Or, choose "None" to use as a constant value.

2. **Adjustment Factor:** *(Optional)*
   - Adds or subtracts a proportion from the main factor.
   - Use negative factor for substraction.
   - Choose a **keyword** to indicate what the factor applies to (e.g., *Current Coffee*, *Total Water*).
   - Or, choose "None" to use as a constant value.

**Supported Keywords:**
\t- **Current Coffee** → Amount of coffee added so far.
\t- **Current Water** → Amount of water added so far.
\t- **Total Coffee** → Total coffee planned for the brew.
\t- **Total Water** → Total water planned for the brew.
\t- **Remaining Coffee** → Remaining coffee to be added (*Total Coffee - Current Coffee*).
\t- **Remaining Water** → Remaining water to be added (*Total Water - Current Water*).
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
                    title: "Duration (seconds) [limit = 300]",
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
                    infoModel: startMethodInfo
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
                    infoModel: skipMethodInfo
                )
                .disabled(skipMethodConstant)
                .grayscale(skipMethodConstant ? 0.5 : 0.0)
            }

            if let message {
                AlphanumericTextField(
                    text: message,
                    style: .titled("Message"),
                    placeholder: "Put all #total.coffee g of coffee to brewer",
                    infoModel: messageInfo
                )
            }

            if let details {
                AlphanumericTextField(
                    text: details,
                    style: .titled("Secondary Message"),
                    placeholder: "Total water: #current.water ml",
                    infoModel: secondaryMessageInfo
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
                TitledContent(title: "Amount (gram)", infoModel: amountInfo) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            NumericTextField(
                                title: "",
                                placeholder: "0.2",
                                range: .init(minimum: 0),
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
                                    keyboardType: .numbersAndPunctuation,
                                    range: .init(minimum: .min, maximum: .max),
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
    static var stub: Self { // TODO: this is in use above, in prod code! Replace it with a use case, whether it returns static element matters less.
        return [
            .init(keyword: "", title: "None"),
            .init(keyword: "#current.coffee", title: "Current Coffee"),
            .init(keyword: "#current.water", title: "Current Water"),
            .init(keyword: "#current.ice", title: "Current Ice"),
            .init(keyword: "#total.coffee", title: "Total Coffee"),
            .init(keyword: "#total.water", title: "Total Water"),
            .init(keyword: "#total.ice", title: "Total Ice"),
            .init(keyword: "#remaining.coffee", title: "Remaining Coffee"),
            .init(keyword: "#remaining.water", title: "Remaining Water"),
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
