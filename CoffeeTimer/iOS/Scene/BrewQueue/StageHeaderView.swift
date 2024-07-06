//
//  StageHeaderView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/07/2024.
//

import SwiftUI

struct StageHeader {
    let lightTitle: String
    let title: String
    var subtext: String? = nil

    static var welcome: StageHeader {
        return StageHeader(lightTitle: "Welcome", title: "All set to go!")
    }
}

struct StageHeaderView: View {
    let header: StageHeader

    var foregroundColor = Color("foregroundPrimary")

    var body: some View {
        VStack {
            Text(header.lightTitle)
                .foregroundColor(foregroundColor.opacity(0.6))
                .font(.title3)

            Text(header.title)
                .foregroundColor(foregroundColor)
                .font(.title)
                .minimumScaleFactor(0.5)

            if let subtext = header.subtext {
                Text(subtext)
                    .foregroundColor(foregroundColor.opacity(0.8))
                    .font(.subheadline)
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 16)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    VStack {
        Spacer()
        StageHeaderView(
            header: .welcome
        )
        Spacer()
        StageHeaderView(
            header: StageHeader(
                lightTitle: "Light Title",
                title: "The Big Main Title",
                subtext: "This is a subtext"
            )
        )
        Spacer()
    }
}
