//
//  CreateRecipeFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

final class CreateRecipeFlowViewModel: ObservableObject {

	@Published var context: CreateRecipeContext = CreateRecipeContext()
}

struct CreateRecipeFlowView: View {

	@StateObject var viewModel: CreateRecipeFlowViewModel

	let closeRequest: () -> Void

	var body: some View {
		createRecipe
	}

	var createRecipe: some View {
		CreateRecipeView(
			viewModel: CreateRecipeViewModel(),
			closeRequest: closeRequest)
		.environmentObject(viewModel.context)
	}
}

struct CreateRecipeFlowView_Previews: PreviewProvider {
	static var previews: some View {
		return CreateRecipeFlowView(viewModel: CreateRecipeFlowViewModel()) { }
	}
}
