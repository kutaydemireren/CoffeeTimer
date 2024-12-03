//
//  PostBrewView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 03/12/2024.
//

import SwiftUI

struct PostBrewView: View {
    var dismiss: () -> Void

    var body: some View {
        VStack {
            Text("Thank you!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Skip")
                }
                .padding(12)
                .foregroundColor(Color("foregroundPrimary"))
                .backgroundSecondary()
                .shadow(color: .blue.opacity(0.2), radius: 8, x: -2, y: -2)
            }
        }
        .backgroundPrimary()
    }
}

#Preview {
    PostBrewView { }
}
