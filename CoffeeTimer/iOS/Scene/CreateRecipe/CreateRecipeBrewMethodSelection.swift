//
//  CreateRecipeBrewMethodSelection.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct BrewMethodView: View {
    let brewMethod: BrewMethod
    var isSelected = false

    private var hasInfo: Bool {
        !brewMethod.info.body.isEmpty
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color("backgroundSecondary").opacity(0.8) : Color("backgroundSecondary").opacity(0.4))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Text(brewMethod.title)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding(.horizontal, 4)
            }

            VStack {
                HStack {
                    Spacer()
                    if hasInfo {
                        InfoButton(
                            infoModel: .init(
                                title: brewMethod.info.title,
                                source: brewMethod.info.source,
                                body: brewMethod.info.body
                            )
                        )
                    }
                }
                .padding([.top, .trailing], 8)
                Spacer()
            }
        }
        .foregroundColor(isSelected ? Color("foregroundPrimary") : Color("foregroundPrimary").opacity(0.8))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CreateRecipeBrewMethodSelection: View {
    private enum ItemStyle {
        case large
        case small
    }

    var columns: [GridItem] {
        switch style {
        case .large:
            [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
        case .small:
            [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
        }
    }

    var height: CGFloat {
        switch style {
        case .large: 150.0
        case .small: 120.0
        }
    }

    private var style: ItemStyle {
        brewMethods.count > 8 ? .small : .large
    }

    @Binding var brewMethods: [BrewMethod]
    @Binding var selectedBrewMethod: BrewMethod?

    var createMethod: () -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(brewMethods) { brewMethod in
                    BrewMethodView(
                        brewMethod: brewMethod,
                        isSelected: selectedBrewMethod == brewMethod
                    )
                    .frame(height: height)
                    .onTapGesture {
                        selectedBrewMethod = brewMethod
                    }
                }
            }
            .padding()

            customMethodAction()
        }
    }

    @ViewBuilder
    private func customMethodAction() -> some View {
        HStack {
            VStack {
                Spacer()

                Button(action: createMethod) {
                    HStack {
                        Image(uiImage: .add)
                            .renderingMode(.template)

                        Text("Or, create your own")
                    }
                    .foregroundColor(Color("foregroundPrimary"))
                }
                .padding()
                .backgroundSecondary(opacity: 0.6)
            }
        }
    }
}

struct CreateRecipeBrewMethodSelection_Previews: PreviewProvider {
    private static var methodsSmall: [BrewMethod] {
        [
            .preview(title: "V60"),
            .preview(title: "V60 Single"),
            .preview(title: "V60 Iced"),
            .preview(title: "French Press"),
            .preview(title: "Chemex"),
            .preview(title: "Aeropress"),
            .preview(title: "V60"),
            .v60Single,
        ]
    }

    private static var methodsLarge: [BrewMethod] {
        [
            .preview(title: "V60"),
            .preview(title: "V60 Single"),
            .preview(title: "V60 Iced"),
            .preview(title: "French Press"),
            .preview(title: "Chemex"),
            .preview(title: "Aeropress"),
            .preview(title: "V60"),
            .v60Single,
            .preview(title: "V60 Iced"),
            .preview(title: "French Press"),
            .preview(title: "Chemex"),
            .preview(title: "Aeropress"),
            .preview(title: "V60"),
            .preview(title: "French Press"),
        ]
    }

    static var previews: some View {
        TabView {
            CreateRecipeBrewMethodSelection(
                brewMethods: .constant(methodsSmall),
                selectedBrewMethod: .constant(.v60Single),
                createMethod: { }
            )

            CreateRecipeBrewMethodSelection(
                brewMethods: .constant(methodsLarge),
                selectedBrewMethod: .constant(.v60Single),
                createMethod: { }
            )
        }
        .tabViewStyle(.page)
        .backgroundPrimary()
    }
}

// TODO: move to preview content
extension BrewMethod {
    static func preview(title: String) -> Self {
        return .init(
            id: UUID().uuidString,
            title: title,
            path: "path",
            isIcedBrew: false,
            cupsCount: .unlimited,
            ratios: [],
            info: .empty
        )
    }

    static var v60Single: Self {
        return BrewMethod(
            id: "v60-single",
            title: "V60 Single",
            path: "/v60-single", 
            isIcedBrew: false,
            cupsCount: .init(minimum: 1, maximum: 1),
            ratios: [
                .ratio16,
                .ratio18,
                .ratio20
            ],
            info: .init(title: "v60 single title", body: "v60 single body")
        )
    }

    static var v60Iced: Self {
        return BrewMethod(
            id: "v60-iced",
            title: "V60 Iced",
            path: "/v60-iced",
            isIcedBrew: true,
            cupsCount: .unlimited,
            ratios: [
                .ratio16,
                .ratio17,
                .ratio18
            ],
            info: .init(title: "v60 iced title", body: "v60 iced body")
        )
    }

    static func frenchPress(path: String = "/french-press") -> Self {
        return BrewMethod(
            id: "french-press",
            title: "French Press",
            path: path,
            isIcedBrew: false,
            cupsCount: .init(minimum: 1, maximum: 5),
            ratios: [
                .ratio17,
                .ratio18,
                .ratio20
            ],
            info: .init(title: "french-press title", body: "french-press body")
        )
    }
}
