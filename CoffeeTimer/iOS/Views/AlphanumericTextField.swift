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

    init(
        text: Binding<String>,
        placeholder: String,
        style: Style
    ) {
        _text = text
        self.style = style
        self.placeholder = placeholder
    }

    // TODO: remove
    /// Temporary (legacy) initialiser. Will be removed
    init(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) {
        _text = text
        self.style = title.isEmpty ? .plain : .titled(title)
        self.placeholder = placeholder
    }

    /// The text to display and edit.
    @Binding var text: String

    let style: Style
    let placeholder: String

    var body: some View {
        switch style {
        case .plain:
            textField
        case .titled(let title):
            TitledContent(title: title) {
                textField
            }
        }
    }

    @ViewBuilder
    private var textField: some View {
        TextField(text: $text) {
            Text(placeholder)
                .foregroundColor(Color("foregroundPrimary").opacity(0.3))
        }
        .textFieldStyle(.plain)
        .foregroundColor(Color("foregroundPrimary"))
        .padding()
        .backgroundSecondary()
    }
}

struct AlphanumericTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            AlphanumericTextField(text: .constant(""), placeholder: "placeholder", style: .titled("titled"))
                .padding()
            Spacer()
            AlphanumericTextField(text: .constant(""), placeholder: "placeholder", style: .plain)
                .padding()
            Spacer()
        }
    }
}
