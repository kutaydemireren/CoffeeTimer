//
//  AlphanumericTextField.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct AlphanumericTextField: View {
    
    let title: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TitledContent(title: title) {
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
}

struct AlphanumericTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            AlphanumericTextField(title: "How u doin?", placeholder: "placeholder", text: .constant(""))
                .padding()
            Spacer()
        }
        .background(Color.black)
    }
}
