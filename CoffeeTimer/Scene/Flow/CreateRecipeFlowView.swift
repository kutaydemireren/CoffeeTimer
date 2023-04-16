//
//  CreateRecipeFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

struct CreateRecipeFlowView: View {

	@StateObject var viewModel: FlowViewModel

	let closeRequest: () -> Void

	var body: some View {
		ZStack {
			createRecipe()
		}
	}

	func createRecipe() -> some View {
		CreateRecipeView(viewModel: CreateRecipeViewModel(), closeRequest: closeRequest)
	}
}

struct CreateRecipeFlowView_Previews: PreviewProvider {
    static var previews: some View {
		CreateRecipeFlowView(viewModel: .init()) { }
    }
}
