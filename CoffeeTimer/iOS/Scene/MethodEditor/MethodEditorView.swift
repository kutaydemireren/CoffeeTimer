//
//  MethodEditorView.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI

/// One scrolling screen that always shows the whole method: name and icon, "Written for", the steps and a footer.
struct MethodEditorView: View {
    @ObservedObject var viewModel: MethodEditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeaderView(close: viewModel.close, primaryTitle: "Save", primary: viewModel.save)

            if let message = viewModel.validationMessage {
                validationBanner(message)
            }

            ScrollView {
                VStack(spacing: 16) {
                    nameSection
                    writtenForSection
                    stepsSection
                    footer
                    tryItButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .backgroundPrimary()
        .safeAreaInset(edge: .bottom) {
            if let deleted = viewModel.deletedStep {
                UndoBanner(text: "Deleted \u{201C}\(deleted.step.kind.title)\u{201D} step", undo: viewModel.undoDeleteStep)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.default, value: viewModel.deletedStep?.step.id)
        .animation(.default, value: viewModel.validationMessage)
        .sheet(isPresented: paletteBinding) {
            StepPaletteView(select: viewModel.insert(kind:))
                .presentationDetents([.medium])
        }
        .sheet(item: editingStepBinding) { item in
            if let step = viewModel.binding(forStep: item.id) {
                StepSheetView(viewModel: viewModel, step: step)
                    .keyboardToolbarHost()
            }
        }
        .sheet(isPresented: $viewModel.isWrittenForPresented) {
            WrittenForSheet(viewModel: viewModel)
                .keyboardToolbarHost()
        }
        .fullScreenCover(isPresented: $viewModel.isTryItPresented) {
            MethodTryItView(recipe: viewModel.dryRunRecipe(), speedUp: MethodEditorViewModel.tryItSpeedUp) {
                viewModel.isTryItPresented = false
            }
        }
        .confirmationDialog("Keep your changes?", isPresented: $viewModel.isClosePromptPresented, titleVisibility: .visible) {
            Button("Keep as draft") { viewModel.keepDraftAndClose() }
            Button("Discard changes", role: .destructive) { viewModel.discardAndClose() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("A draft can be continued from \u{201C}Or, create your own\u{201D}.")
        }
        .confirmationDialog(saveChoiceTitle, isPresented: $viewModel.isSaveChoicePresented, titleVisibility: .visible) {
            Button("Update everywhere") { viewModel.perform(mode: .updateEverywhere) }
            Button("Save as new") { viewModel.perform(mode: .asNew) }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Update everywhere changes the steps of those recipes too. Save as new leaves them as they are.")
        }
    }

    private var saveChoiceTitle: String {
        viewModel.recipesUsingCount == 1
            ? "1 recipe uses this method"
            : "\(viewModel.recipesUsingCount) recipes use this method"
    }

    private var paletteBinding: Binding<Bool> {
        Binding(
            get: { viewModel.paletteInsertIndex != nil },
            set: { if !$0 { viewModel.paletteInsertIndex = nil } }
        )
    }

    private struct EditingStep: Identifiable { let id: UUID }

    private var editingStepBinding: Binding<EditingStep?> {
        Binding(
            get: { viewModel.editingStepID.map(EditingStep.init) },
            set: { viewModel.editingStepID = $0?.id }
        )
    }

    // MARK: Sections

    @ViewBuilder
    private func validationBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.circle")
            Text(message)
                .font(.callout)
            Spacer()
        }
        .padding()
        .foregroundStyle(Color("foregroundPrimary"))
        .backgroundSecondary()
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .transition(.opacity)
    }

    private var nameSection: some View {
        VStack(spacing: 12) {
            AlphanumericTextField(
                text: $viewModel.draft.name,
                style: .titled("Name"),
                placeholder: "My Kalita Wave"
            )
            .highlightAnimation(isAnimating: $viewModel.animateName)

            MethodIconPicker(selectedIcon: $viewModel.draft.iconName)
        }
    }

    private var writtenForSection: some View {
        Button {
            viewModel.isWrittenForPresented = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Written for")
                        .font(.headline)
                    Text(viewModel.writtenForText)
                        .foregroundStyle(Color("foregroundPrimary"))
                    if let ratio = viewModel.ratioText {
                        Text(ratio)
                            .font(.subheadline)
                            .foregroundStyle(Color("foregroundSecondary"))
                    }
                }
                Spacer()
                Image(systemName: "pencil")
            }
            .foregroundStyle(Color("foregroundPrimary"))
            .padding()
            .backgroundSecondary()
        }
        .buttonStyle(.plain)
        .highlightAnimation(isAnimating: $viewModel.animateDose)
    }

    private var stepsSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Steps")
                    .font(.headline)
                Spacer()
            }
            .foregroundStyle(Color("foregroundPrimary"))
            .padding(.horizontal, 4)

            if viewModel.draft.steps.isEmpty {
                Text("Tap + to add the first step")
                    .font(.subheadline)
                    .foregroundStyle(Color("foregroundSecondary"))
                    .padding(.vertical, 8)
            }

            ForEach(Array(viewModel.draft.steps.enumerated()), id: \.element.id) { index, step in
                if index > 0 {
                    AddStepButton(compact: true) { viewModel.openPalette(at: index) }
                }
                MethodStepRowView(
                    number: index + 1,
                    step: step,
                    preview: viewModel.preview.steps[safe: index],
                    isHighlighted: step.id == viewModel.highlightedStepID
                )
                .onTapGesture {
                    viewModel.editingStepID = step.id
                }
            }

            AddStepButton(compact: false) { viewModel.openPalette(at: viewModel.draft.steps.count) }
                .highlightAnimation(isAnimating: $viewModel.animateSteps)
        }
    }

    private var footer: some View {
        MethodFooterView(
            preview: viewModel.preview,
            hasPour: viewModel.hasPour,
            lastPourIsRest: viewModel.lastPourIsRest,
            makeLastPourTheRest: viewModel.makeLastPourTheRest,
            matchWaterToPoured: viewModel.matchWaterToPoured,
            addPour: viewModel.addPour
        )
        .highlightAnimation(isAnimating: $viewModel.animateFooter)
    }

    private var tryItButton: some View {
        Button(action: viewModel.tryIt) {
            HStack {
                Image(systemName: "play.fill")
                Text("Try it")
                    .bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Color("foregroundPrimary"))
        .backgroundSecondary()
        .shadow(color: .blue.opacity(0.2), radius: 8, x: -2, y: -2)
        .disabled(viewModel.draft.steps.isEmpty)
        .opacity(viewModel.draft.steps.isEmpty ? 0.5 : 1)
    }
}

/// The "+" that adds a step, with the plus image and style of "Or, create your own".
struct AddStepButton: View {
    var compact: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(uiImage: .add)
                    .renderingMode(.template)
                if !compact {
                    Text("Add a step")
                }
            }
            .foregroundStyle(Color("foregroundPrimary").opacity(compact ? 0.5 : 1))
            .padding(compact ? 4 : 12)
            .frame(maxWidth: compact ? nil : .infinity)
        }
        .accessibilityLabel(compact ? "Insert a step here" : "Add a step")
        .modifier(AddStepBackground(compact: compact))
    }
}

private struct AddStepBackground: ViewModifier {
    let compact: Bool

    func body(content: Content) -> some View {
        if compact {
            content
        } else {
            content.backgroundSecondary(opacity: 0.6)
        }
    }
}

/// A row of the existing brewer icons to pick the method's grid icon from.
struct MethodIconPicker: View {
    @Binding var selectedIcon: String

    private var icons: [String] {
        MethodDraft.icons.contains(selectedIcon) || selectedIcon.isEmpty
            ? MethodDraft.icons
            : [selectedIcon] + MethodDraft.icons
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(icons, id: \.self) { icon in
                Button {
                    selectedIcon = icon
                } label: {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("backgroundSecondary").opacity(selectedIcon == icon ? 0.8 : 0.3))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(icon.replacingOccurrences(of: "recipe-profile-", with: ""))
                .accessibilityAddTraits(selectedIcon == icon ? .isSelected : [])
            }
        }
        .foregroundStyle(Color("foregroundPrimary"))
    }
}
