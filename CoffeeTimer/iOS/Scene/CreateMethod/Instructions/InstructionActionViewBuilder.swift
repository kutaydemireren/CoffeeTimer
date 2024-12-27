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

Use "User Interactive" if a confirmation can be useful to begin the step, letting the countdown begin.
"""
    )
}

private var skipMethodInfo: InfoModel {
    .init(
        title: "Skip Step Method",
        body: """
Flag to decide whether the queue should automatically skip the current step (once the step is completed).
Only effective at the end of the each step.

Use "User Interactive" if a confirmation can be useful to end the step, and to go to the next one.
"""
    )
}

private var messageInfo: InfoModel {
    .init(
        title: "Message",
        body: """
Message is the main text displayed at the top, prominently.

**Supported Keywords: (X = "coffee", "water", "ice")**
\t- **#current.amount** → Step-specific amount, dynamically calculated for the current instruction.
\t- **#current.duration** → Duration for the current step (0 if not set)
\t- **#current.X** → Amount of X added so far.
\t- **#total.X** → Total X planned for the brew.
\t- **#remaining.X** → Remaining X to be added (*total.X - current.X*).
"""
    )
}

private var secondaryMessageInfo: InfoModel {
    .init(
        title: "Secondary Message",
        body: """
Secondary message is the text displayed below the main text, less prominent but visible enough.

**Supported Keywords: (X = "coffee", "water", "ice")**
\t- **#current.amount** → Step-specific amount, dynamically calculated for the current instruction.
\t- **#current.duration** → Duration for the current step (0 if not set)
\t- **#current.X** → Amount of X added so far.
\t- **#total.X** → Total X planned for the brew.
\t- **#remaining.X** → Remaining X to be added (*total.X - current.X*).
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

**Supported Keywords: (X = "Coffee", "Water", "Ice")**
\t- **Current X** → Amount of X added so far.
\t- **Total X** → Total X planned for the brew.
\t- **Remaining X** → Remaining X to be added (*Total X - Current X*).
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

    private static let keywords: [KeywordItem] = {
        var keywords: [KeywordItem] = [.init(keyword: "",title: "None")]
        keywords.append(contentsOf: InstructionKeyword.userAllowedKeywords.compactMap { $0.keywordItem })
        return Array(Set(keywords))
    }()
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
                                    ForEach(Self.keywords) { ratio in
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
                                    ForEach(Self.keywords) { ratio in
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

#if DEBUG
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
#endif
