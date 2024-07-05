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

    let title: String
    let placeholder: String
    var keyboardType: KeyboardType = .decimal
    @FocusState private var isFocused: Bool

    @Binding var input: Double

    @State private var displayText: String = ""

    var didUpdate: ((Double) -> Void)?

    var body: some View {

        TitledContent(title: title) {
            TextField(text: $displayText) {
                Text(placeholder)
                    .foregroundColor(Color("foregroundPrimary").opacity(0.5))
            }
            .textFieldStyle(.plain)
            .keyboardType(keyboardType.uiKeyboardType)
            .focused($isFocused)
            .foregroundColor(Color("foregroundPrimary"))
            .onChange(of: displayText, perform: filterNonNumerics(_:))
            .onChange(of: input, perform: setDisplayText(_:))
            .padding()
            .backgroundSecondary()
        }
    }

    private func filterNonNumerics(_ newValue: String) {
        guard isFocused else {
            return
        }

        let input = Double(newValue.filteringNonNumerics()) ?? 0.0
        self.input = input
        didUpdate?(input)
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
                input: .constant(2.0)) { _ in }
                .padding()

            NumericTextField(
                title: "How many cups?",
                placeholder: "placeholder",
                input: .constant(2.0)) { _ in }
                .padding()
            Spacer()
        }
        .background(Color.black)
    }
}
