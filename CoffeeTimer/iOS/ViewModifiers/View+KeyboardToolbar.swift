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

    /// Keyboard toolbars (the "Done" button above the keyboard) only show inside a navigation stack.
    /// Wraps a presented sheet or cover in one, with its bar hidden.
    func keyboardToolbarHost() -> some View {
        NavigationStack {
            self.toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct KeyboardDoneToolbarModifier: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .toolbar {
                if isFocused {
                    ToolbarItemGroup(placement: .keyboard) {
                        VStack {
                            HStack {
                                Spacer()
                                Button("Done") {
                                    content.hideKeyboard()
                                }
                                .bold()
                                .foregroundStyle(Color("backgroundSecondary"))
                                .padding(8)
                                .glassEffect()
                            }
                            Spacer()
                                .padding(.bottom, 8)
                        }
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
            }
    }
}
