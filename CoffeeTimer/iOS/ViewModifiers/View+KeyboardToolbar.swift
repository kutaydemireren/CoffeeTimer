//
//  View+KeyboardToolbar.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/10/2025.
//

import SwiftUI

extension View {
    func keyboardDoneToolbar(isFocused: Bool) -> some View {
        self.modifier(KeyboardDoneToolbarModifier(isFocused: isFocused))
    }
}

struct KeyboardDoneToolbarModifier: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            // Toolbar on keyboard has a jumpy behaviour on iOS 26.
            // I find it not worthy of having it, so simply opt-in not to show.
            content
        } else {
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
