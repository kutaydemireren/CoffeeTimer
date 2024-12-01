//
//  View+Responder.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 15/04/2023.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func hideKeyboardOnTap() -> some View {
        self.modifier(HideKeyboardModifier())
    }
}

struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background( // Attach the gesture to a clear background layer
                Color.clear
                    .contentShape(Rectangle()) // Ensure the tap gesture covers the full area
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            content.hideKeyboard()
                        }
                    )
            )
    }
}
