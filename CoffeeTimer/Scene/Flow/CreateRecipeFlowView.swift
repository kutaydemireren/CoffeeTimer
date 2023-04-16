//
//  CreateRecipeFlowView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 16/04/2023.
//

import SwiftUI

final class CreateRecipeFlowViewModel: ObservableObject {

	@Published var navigationPath: [Screen] = []
}

struct CreateRecipeFlowView: View {

	@StateObject var viewModel: CreateRecipeFlowViewModel

	let closeRequest: () -> Void

	var body: some View {
		NavigationStack(path: $viewModel.navigationPath) {
			VStack() {
				CreateRecipeBrewMethodSelection { _ in
					viewModel.navigationPath.append(.createRecipe)
				}
			}
			.navigationDestination(for: Screen.self) { screen in
				switch screen {
				case .brewQueue:
					EmptyView()
				case .createRecipe:
					createRecipe()
						.navigationBarBackButtonHidden()
				}
			}
		}
	}

	func createRecipe() -> some View {
		CreateRecipeView(viewModel: CreateRecipeViewModel(), closeRequest: closeRequest)
	}
}

struct CreateRecipeFlowView_Previews: PreviewProvider {
    static var previews: some View {
		return CreateRecipeFlowView(viewModel: CreateRecipeFlowViewModel()) { }
    }
}
