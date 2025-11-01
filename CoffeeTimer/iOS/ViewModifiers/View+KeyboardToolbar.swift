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
