//
//  View+ClearButton.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct ClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.init("backgroundPrimary"))
                }
                .padding(.trailing, 8)
            }
        }
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        modifier(ClearButton(text: text))
    }
}

