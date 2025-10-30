//
//  AlphanumericTextField.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct AlphanumericTextField: View {

    enum Style {
        case plain
        case titled(String)
    }

    /// The text to display and edit.
    @Binding var text: String

    @FocusState private var isFocused: Bool

    let style: Style
    let placeholder: String
    var infoModel: InfoModel? = nil

    var body: some View {
        VStack {
            switch style {
            case .plain:
                textField(info: infoModel)
            case .titled(let title):
                TitledContent(title: title, infoModel: infoModel) {
                    textField(info: nil)
                }
            }
        }
        .modifier(KeyboardToolbarModifier(isFocused: isFocused))
    }

    @ViewBuilder
    private func textField(info: InfoModel?) -> some View {
        HStack {
            TextField(text: $text) {
                Text(placeholder)
                    .foregroundColor(Color("foregroundPrimary").opacity(0.3))
            }
            .textFieldStyle(.plain)
            .foregroundColor(Color("foregroundPrimary"))
            .padding()
            .focused($isFocused)
            .backgroundSecondary()

            if let info {
                InfoButton(infoModel: info)
            }
        }
    }
}

// Keyboard toolbar modifier that only shows on iOS 25 and below
private struct KeyboardToolbarModifier: ViewModifier {
    let isFocused: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            // iOS 26+: Don't show keyboard toolbar to avoid extra space
            content
        } else {
            // iOS 25 and below: Show Done button for keyboards without return key
            content
                .toolbar {
                    if isFocused {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                content.hideKeyboard()
                            }
                            .bold()
                            .foregroundColor(Color("backgroundSecondary"))
                        }
                    }
                }
        }
    }
}

struct AlphanumericTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            AlphanumericTextField(text: .constant(""), style: .titled("titled"), placeholder: "placeholder")
                .padding()
            Spacer()
            AlphanumericTextField(text: .constant(""), style: .plain, placeholder: "placeholder")
                .padding()
            Spacer()
        }
    }
}
