//
//  CreateMethodView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

final class CreateMethodViewModel: ObservableObject {
    private let pageCount = 2

    @Published var selectedPage = 1
    @Published var canCreate: Bool = false

    private let createBrewMethodUseCase: CreateBrewMethodUseCase

    init(
        createBrewMethodUseCase: CreateBrewMethodUseCase = CreateBrewMethodUseCaseImp()
    ) {
        self.createBrewMethodUseCase = createBrewMethodUseCase
    }

    func nextPage(in context: CreateBrewMethodContext) {
        var newSelectedPage = 1

        if selectedPage < pageCount {
            newSelectedPage = (selectedPage % pageCount) + 1
        } else {
            newSelectedPage = getNextMissingPage(in: context)
        }

        selectedPage = newSelectedPage
    }

    private func getNextMissingPage(in context: CreateBrewMethodContext) -> Int {
        do {
            let _ = try createBrewMethodUseCase.canCreate(from: context)
        } catch let error as CreateBrewMethodUseCaseError {
            switch error {
            case .missingMethodTitle:
                return 1
            case .missingInstructions:
                return 2
            }
        } catch _ {
            // Unknown error
        }

        return pageCount
    }

    func canCreate(from context: CreateBrewMethodContext) -> Bool {
        do {
            return try createBrewMethodUseCase.canCreate(from: context)
        } catch {
            return false
        }
    }

    func create(from context: CreateBrewMethodContext) async throws {
        try await createBrewMethodUseCase.create(from: context)
    }

    func didUpdate(context: CreateBrewMethodContext) {
        canCreate = canCreate(from: context)
    }
}

struct CreateMethodView: View {
    @StateObject var viewModel: CreateMethodViewModel
    @EnvironmentObject var context: CreateBrewMethodContext

    var close: () -> Void
    var selectItem: (RecipeInstructionActionItem) -> Void

    var body: some View {
        PagerView(
            selectedPage: $viewModel.selectedPage,
            canCreate: $viewModel.canCreate,
            close: close,
            create: {
                try await viewModel.create(from: context)
            },
            nextPage: {
                withAnimation { viewModel.nextPage(in: context) }
            },
            content: {
                // Wrapping in ZStack helps with the scrolling animation amongst pages
                ZStack {
                    CreateMethodDetailsView()
                }
                .tag(1)

                ZStack {
                    CreateMethodInstructionsView(didSelect: selectItem)
                }
                .tag(2)
            }
        )
        .onChange(of: context.methodTitle, perform: didUpdate(_:))
        .onChange(of: context.instructions, perform: didUpdate(_:))
        .hideKeyboardOnTap()
    }

    private func didUpdate<T>(_ newValue: T?) {
        viewModel.didUpdate(context: context)
    }
}

#if DEBUG
#Preview {
    CreateMethodView(
        viewModel: CreateMethodViewModel(),
        close: { },
        selectItem: { _ in }
    )
    .environmentObject(stubContext())
}

fileprivate func stubContext() -> CreateBrewMethodContext {
    let context = CreateBrewMethodContext()
    context.instructions = .stub
    return context
}
#endif
