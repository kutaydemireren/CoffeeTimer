//
//  CreateMethodView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

//import SwiftUI

//struct CreateMethodView: View {
//
//    @Binding var selectedRatio: CoffeeToWaterRatio?
//    @Binding var allRatios: [CoffeeToWaterRatio]
//
//    var body: some View {
//        TitledContent(title: "Create your own or select a template to start with") {
//            Menu {
//                Picker(selection: $selectedRatio, label: EmptyView()) {
//                    ForEach(allRatios) { ratio in
//                        Text(ratio.title)
//                            .tag(ratio as CoffeeToWaterRatio?)
//                    }
//                }
//            } label: {
//                Text("Some text as picker label")
//            }
//        }
//    }
//}

//#Preview {
//    CreateMethodView()
//}
