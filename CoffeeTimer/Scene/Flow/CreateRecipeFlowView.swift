//
//  CreateRecipeFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

final class CreateRecipeFlowViewModel: ObservableObject {

	@Published var context: CreateRecipeContext = CreateRecipeContext()

	@Published var navigationPath: [Screen] = []
}

struct CreateRecipeFlowView: View {

	@StateObject var viewModel: CreateRecipeFlowViewModel

	let closeRequest: () -> Void

	var body: some View {
		NavigationStack(path: $viewModel.navigationPath) {
			createRecipe
				.navigationBarBackButtonHidden()
				.navigationDestination(for: Screen.self) { screen in
					switch screen {
					case .brewQueue:
						EmptyView()
					case .createRecipe:
						EmptyView()
					}
				}
		}
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
