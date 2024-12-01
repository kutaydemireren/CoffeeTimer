//
//  InfoView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 30/11/2024.
//

import SwiftUI

struct InfoView: View {
    let model: InfoModel

    var body: some View {
        VStack {
            Text(model.title)
                .font(.title2)
                .bold()

            if let source = model.source {
                Text(try! AttributedString(
                    markdown: source,
                    options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
                ))
                .bold()
                .italic()
            }

            Text(try! AttributedString(
                markdown: model.body,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            ))
            .padding(.vertical)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(Color("foregroundPrimary"))
        .backgroundPrimary()
    }
}

#Preview {
    InfoView(
        model: .init(
            title: "The Title",
            source: "[*Learn it from John Doe*](www.example.com)",
            body: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam dignissim diam vitae ex mollis consectetur. Sed elit ipsum, fermentum non urna sit amet, fermentum bibendum purus. Nunc condimentum enim nec lacinia tristique. Duis ac blandit massa. Sed auctor purus augue, vitae fringilla nibh venenatis scelerisque. Aliquam id mattis tortor. Duis eget enim quis orci consequat venenatis.
"""
        )
    )
}
