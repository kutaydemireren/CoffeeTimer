//
//  View+Background.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct BackgroundPrimaryViewModifier: ViewModifier {
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .background(BackgroundPrimary(opacity: opacity))
    }
}

struct BackgroundPrimary: View {
    let opacity: Double

    var body: some View {
        Rectangle()
            .fill(
                Color("backgroundPrimary").opacity(opacity)
            )
            .ignoresSafeArea()
    }
}

struct BackgroundSecondaryViewModifier: ViewModifier {
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .background(BackgroundSecondary(opacity: opacity))
    }
}

struct BackgroundSecondary: View {
    let opacity: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(LinearGradient(
                colors: [
                    Color("backgroundSecondary").opacity(opacity)
                ],
                startPoint: .leading,
                endPoint: .trailing
            ))
    }
}

extension View {
    func backgroundPrimary(opacity: Double = 1.0) -> some View {
        modifier(BackgroundPrimaryViewModifier(opacity: opacity))
    }
    
    func backgroundSecondary(opacity: Double = 0.8) -> some View {
        modifier(BackgroundSecondaryViewModifier(opacity: opacity))
    }
}
