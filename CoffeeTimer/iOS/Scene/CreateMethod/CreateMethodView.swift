//
//  CreateMethodView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 20/07/2024.
//

import SwiftUI

enum CreateMethodMissingField {
    case methodTitle
    case instructions
}

final class CreateMethodViewModel: ObservableObject {
    private let pageCount = 2

    @Published var selectedPage = 1
    @Published var canCreate: Bool = false
    
    @Published var animateMethodTitle = false
    @Published var animateInstructions = false

    private let createBrewMethodUseCase: CreateBrewMethodUseCase
    private var analyticsTracker: AnalyticsTracker

    init(
        createBrewMethodUseCase: CreateBrewMethodUseCase = CreateBrewMethodUseCaseImp(),
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp()
    ) {
        self.createBrewMethodUseCase = createBrewMethodUseCase
        self.analyticsTracker = analyticsTracker
        analyticsTracker.track(event: AnalyticsEvent(name: "create_method_opened"))
    }

    func nextPage(in context: CreateBrewMethodContext) {
        var newSelectedPage = 1
        var missingField: CreateMethodMissingField?

        if selectedPage < pageCount {
            newSelectedPage = (selectedPage % pageCount) + 1
        } else {
            let result = getNextMissingPage(in: context)
            newSelectedPage = result.page
            missingField = result.missingField
        }

        selectedPage = newSelectedPage
        
        if let missingField = missingField {
            triggerAnimation(for: missingField)
        }
    }
    
    private func triggerAnimation(for field: CreateMethodMissingField) {
        animateMethodTitle = false
        animateInstructions = false
        
        // Small delay to wait for page transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            switch field {
            case .methodTitle:
                self?.animateMethodTitle = true
            case .instructions:
                self?.animateInstructions = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                switch field {
                case .methodTitle:
                    self?.animateMethodTitle = false
                case .instructions:
                    self?.animateInstructions = false
                }
            }
        }
    }

    private func getNextMissingPage(in context: CreateBrewMethodContext) -> (page: Int, missingField: CreateMethodMissingField?) {
        do {
            let _ = try createBrewMethodUseCase.canCreate(from: context)
            analyticsTracker.track(event: AnalyticsEvent(
                name: "create_method_validated",
                parameters: ["result": "pass"]
            ))
            return (pageCount, nil)
        } catch let error as CreateBrewMethodUseCaseError {
            let missingField: CreateMethodMissingField
            switch error {
            case .missingMethodTitle:
                missingField = .methodTitle
            case .missingInstructions:
                missingField = .instructions
            }
            analyticsTracker.track(event: AnalyticsEvent(
                name: "create_method_validated",
                parameters: [
                    "result": "fail",
                    "missing_field": fieldName(for: missingField)
                ]
            ))
            switch missingField {
            case .methodTitle:
                return (1, .methodTitle)
            case .instructions:
                return (2, .instructions)
            }
        } catch _ {
            // Unknown error
        }

        return (pageCount, nil)
    }
    
    private func fieldName(for field: CreateMethodMissingField) -> String {
        switch field {
        case .methodTitle: return "method_title"
        case .instructions: return "instructions"
        }
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
        
        let isIced = context.instructions.contains { item in
            switch item.action {
            case .put(let putModel):
                return putModel.ingredient == .ice
            default:
                return false
            }
        }
        let stepCount = context.instructions.count
        
        analyticsTracker.track(event: AnalyticsEvent(
            name: "method_created",
            parameters: [
                "iced": isIced,
                "step_count": stepCount
            ]
        ))
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
                    CreateMethodDetailsView(
                        animateMethodTitle: $viewModel.animateMethodTitle
                    )
                }
                .tag(1)

                ZStack {
                    CreateMethodInstructionsView(
                        animateInstructions: $viewModel.animateInstructions,
                        didSelect: selectItem
                    )
                }
                .tag(2)
            }
        )
        .onChange(of: context.methodTitle, perform: didUpdate(_:))
        .onChange(of: context.instructions, perform: didUpdate(_:))
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
