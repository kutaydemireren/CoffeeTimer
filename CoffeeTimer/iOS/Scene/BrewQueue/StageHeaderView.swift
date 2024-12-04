//
//  StageHeaderView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 06/07/2024.
//

import SwiftUI

struct StageHeader {
    var lightTitle: String? = nil
    var title: String? = nil
    var subtext: String? = nil
    
    static var welcomeNotReady: StageHeader {
        return StageHeader(lightTitle: "Welcome", title: "Time to craft your masterpiece!")
    }

    static var welcomeReady: StageHeader {
        return StageHeader(lightTitle: "Welcome", title: "All set to go!")
    }
}

struct StageHeaderView: View {
    let header: StageHeader
    
    var foregroundColor = Color("foregroundPrimary")
    
    var body: some View {
        VStack {
            if let lightTitle = header.lightTitle {
                Text(lightTitle)
                    .foregroundColor(foregroundColor.opacity(0.6))
                    .font(.title3)
            }

            if let title = header.title {
                Text(title)
                    .foregroundColor(foregroundColor)
                    .font(.title)
                    .minimumScaleFactor(0.5)
            }

            if let subtext = header.subtext {
                Text(subtext)
                    .foregroundColor(foregroundColor)
                    .font(.title3)
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
            header: .welcomeReady
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
