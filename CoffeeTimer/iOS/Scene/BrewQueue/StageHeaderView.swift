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

    static var welcome: StageHeader {
        return StageHeader(lightTitle: "Welcome", title: "All set to go!")
    }
}

struct StageHeaderView: View {
    let stageHeader: StageHeader
    
    var foregroundColor = Color("foregroundPrimary")

    var body: some View {
        VStack {
            Text(stageHeader.lightTitle)
                .foregroundColor(foregroundColor.opacity(0.8))
                .font(.title3)

            Text(stageHeader.title)
                .foregroundColor(foregroundColor)
                .font(.title)
                .minimumScaleFactor(0.5)
        }
        .shadow(color: .black.opacity(0.2), radius: 16)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    StageHeaderView(stageHeader: .welcome)
}
