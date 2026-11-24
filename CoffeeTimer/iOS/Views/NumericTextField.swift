//
//  NumericTextField.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 15/04/2023.
//

import SwiftUI

struct NumericTextField: View {

    enum KeyboardType {
        case decimal
        case number
        case numbersAndPunctuation

        var uiKeyboardType: UIKeyboardType {
            switch self {
            case .decimal:
                return .decimalPad
            case .number:
                return .numberPad
            case .numbersAndPunctuation:
                return .numbersAndPunctuation
            }
        }
    }

    /// How the number is typed and shown.
    enum Format {
        /// A plain number, for example grams.
        case number
        /// Seconds typed and shown as m:ss, for example "1:15". A number without a colon is read as seconds.
        case minutesSeconds
    }

    struct Range {
        var minimum: Int = 1
        var maximum: Int = .max
    }

    let title: String
    let placeholder: String
    var keyboardType: KeyboardType = .decimal
    var range = Range()
    var format: Format = .number

    private var isSingleValue: Bool {
        return range.minimum == range.maximum
    }

    @FocusState private var isFocused: Bool

    @Binding var input: Double
    @State private var displayText: String = ""

    var body: some View {
        VStack {
            if !title.isEmpty {
                TitledContent(title: title) {
                    textField
                }
            } else {
                textField
            }
        }
        .keyboardDoneToolbar(isFocused: isFocused)
    }

    @ViewBuilder
    private var textField: some View {
        TextField(text: isSingleValue ? .constant("\(range.minimum)") : $displayText) {
            Text(placeholder)
                .foregroundStyle(Color("foregroundPrimary").opacity(0.5))
        }
        .multilineTextAlignment(.center)
        .disabled(isSingleValue)
        .textFieldStyle(.plain)
        .keyboardType(format == .minutesSeconds ? .numbersAndPunctuation : keyboardType.uiKeyboardType)
        .focused($isFocused)
        .tint(Color("backgroundPrimary").opacity(0.6))
        .foregroundStyle(Color("foregroundPrimary"))
        .onChange(of: displayText) { _, newValue in didUpdate(displayText: newValue) }
        .onChange(of: input) { _, newValue in setDisplayText(newValue) }
        .onChange(of: isFocused) { _, focused in
            // A time typed only partly ("1:") shows the value it stands for once the field is left.
            if !focused, format == .minutesSeconds {
                displayText = input <= 0 ? "" : MethodTimeFormat.clock(UInt(input))
            }
        }
        .padding()
        .backgroundSecondary()
        .onAppear {
            if isSingleValue {
                input = Double(range.minimum)
            }
            setDisplayText(input)
        }
    }

    private func didUpdate(displayText newValue: String) {
        guard isFocused else { return }

        if format == .minutesSeconds {
            // Partial input such as "1:" stays as typed; the value updates once it reads as a time in range.
            if let seconds = MethodTimeFormat.parse(newValue), inRange(input: Double(seconds)) {
                input = Double(seconds)
            }
            return
        }

        guard let newInput = Double(newValue.filteringNonNumerics()), inRange(input: newInput) else {
            guard newValue != "-" else {
                return
            }
            setDisplayText(0)
            return
        }
        input = newInput
    }

    private func inRange(input: Double) -> Bool {
        return input >= Double(range.minimum) && input <= Double(range.maximum)
    }

    private func setDisplayText(_ newValue: Double) {
        if format == .minutesSeconds {
            if MethodTimeFormat.parse(displayText).map(Double.init) != newValue {
                displayText = newValue <= 0 ? "" : MethodTimeFormat.clock(UInt(newValue))
            }
            return
        }
        if Double(displayText) != newValue {
            displayText = newValue == 0 ? "" : "\(newValue)"
        }
    }
}

struct NumericTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            NumericTextField(
                title: "",
                placeholder: "placeholder",
                input: .constant(2.0))
                .padding()

            NumericTextField(
                title: "How many cups?",
                placeholder: "placeholder",
                input: .constant(2.0))
                .padding()
            Spacer()
        }
        .background(Color.black)
    }
}
