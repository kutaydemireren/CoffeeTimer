//
//  View+HighlightAnimation.swift
//  CoffeeTimer
//
//  Created by Auto on 27/11/2024.
//

import SwiftUI

struct HighlightAnimationViewModifier: ViewModifier {
    @Binding var isAnimating: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.1 : 1)
            .animation(
                Animation.default.repeatCount(1, autoreverses: true),
                value: isAnimating
            )
    }
}

extension View {
    func highlightAnimation(isAnimating: Binding<Bool>) -> some View {
        modifier(HighlightAnimationViewModifier(isAnimating: isAnimating))
    }
}
