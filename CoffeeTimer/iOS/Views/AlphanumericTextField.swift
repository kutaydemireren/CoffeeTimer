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
        .keyboardDoneToolbar(isFocused: isFocused)
        .clearButton(text: $text)
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
