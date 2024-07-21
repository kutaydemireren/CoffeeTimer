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

        var uiKeyboardType: UIKeyboardType {
            switch self {
            case .decimal:
                return .decimalPad
            case .number:
                return .numberPad
            }
        }
    }

    struct Range {
        var minimum: Int = 1
        var maximum: Int = .max
    }

    let title: String
    let placeholder: String
    var keyboardType: KeyboardType = .decimal
    var range = Range()

    private var isSingleValue: Bool {
        return range.minimum == range.maximum
    }

    @FocusState private var isFocused: Bool

    @Binding var input: Double
    @State private var displayText: String = ""

    var body: some View {

        if !title.isEmpty {
            TitledContent(title: title) {
                textField
            }
        } else {
            textField
        }

    }

    @ViewBuilder
    private var textField: some View {
        TextField(text: isSingleValue ? .constant("\(range.minimum)") : $displayText) {
            Text(placeholder)
                .foregroundColor(Color("foregroundPrimary").opacity(0.5))
        }
        .multilineTextAlignment(.center)
        .disabled(isSingleValue)
        .textFieldStyle(.plain)
        .keyboardType(keyboardType.uiKeyboardType)
        .focused($isFocused)
        .foregroundColor(Color("foregroundPrimary"))
        .onChange(of: displayText, perform: didUpdate(displayText:))
        .onChange(of: input, perform: setDisplayText(_:))
        .padding()
        .backgroundSecondary()
        .onAppear {
            if isSingleValue {
                input = Double(range.minimum)
            }
        }
    }

    private func didUpdate(displayText newValue: String) {
        guard isFocused else { return }

        guard let newInput = Double(newValue.filteringNonNumerics()), inRange(input: newInput)else {
            setDisplayText(0)
            return
        }
        input = newInput
    }

    private func inRange(input: Double) -> Bool {
        return input >= Double(range.minimum) && input <= Double(range.maximum)
    }

    private func setDisplayText(_ newValue: Double) {
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
