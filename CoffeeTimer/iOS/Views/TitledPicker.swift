//
//  TitledPicker.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

struct TitledPicker<T: Titled & Identifiable & Hashable>: View {
    @Binding var selectedItem: T?
    @Binding var allItems: [T]

    let title: String
    let placeholder: String
    var infoModel: InfoModel? = nil

    var body: some View {
        TitledContent(title: title, infoModel: infoModel) {
            HStack {
                Menu {
                    Picker(selection: $selectedItem, label: EmptyView()) {
                        ForEach(allItems) { ratio in
                            Text(ratio.title)
                                .tag(ratio as T?)
                        }
                    }
                } label: {
                    pickerLabel
                }
            }
        }
        
    }

    private var pickerLabel: some View {
        Text(selectedItem?.title ?? placeholder)
            .foregroundColor(Color("foregroundPrimary").opacity(0.8))
            .padding()
            .backgroundSecondary()
    }
}
