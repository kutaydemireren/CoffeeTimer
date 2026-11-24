//
//  UndoBanner.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI

/// A short message with an Undo button, shown after something was deleted.
struct UndoBanner: View {
    let text: String
    let undo: () -> Void

    var body: some View {
        HStack {
            Text(text)
                .lineLimit(1)
            Spacer()
            Button(action: undo) {
                Text("Undo")
                    .bold()
            }
        }
        .padding()
        .foregroundStyle(Color("foregroundPrimary"))
        .backgroundSecondary()
        .shadow(color: .blue.opacity(0.2), radius: 8, x: -2, y: -2)
    }
}

#Preview {
    UndoBanner(text: "Deleted \u{201C}My V60\u{201D}", undo: { })
        .padding()
        .backgroundPrimary()
}
