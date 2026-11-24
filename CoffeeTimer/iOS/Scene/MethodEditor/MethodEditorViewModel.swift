//
//  MethodEditorViewModel.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import SwiftUI
import Combine

@MainActor
final class MethodEditorViewModel: ObservableObject, Identifiable {
    let id = UUID()

    @Published var draft: MethodDraft {
        didSet { draftDidChange(from: oldValue) }
    }
    @Published private(set) var preview: MethodPreview

    /// The step open in the step sheet.
    @Published var editingStepID: UUID?
    /// Where the step palette inserts, while it is open.
    @Published var paletteInsertIndex: Int?
    @Published var isWrittenForPresented = false
    @Published var isTryItPresented = false
    @Published var isClosePromptPresented = false
    @Published var isSaveChoicePresented = false
    @Published private(set) var recipesUsingCount = 0

    @Published private(set) var validationMessage: String?
    @Published var animateName = false
    @Published var animateSteps = false
    @Published var animateDose = false
    @Published var animateFooter = false
    /// Step ids to highlight, for example a step a validation message is about.
    @Published private(set) var highlightedStepID: UUID?

    /// The step just deleted, with its position, while its Undo is offered.
    @Published private(set) var deletedStep: (step: MethodStep, index: Int)?
    private var deletedStepDismissTask: Task<Void, Never>?

    let didSave = PassthroughSubject<BrewMethod, Never>()
    let didClose = PassthroughSubject<Void, Never>()

    /// The draft as it was opened; Close only asks when the draft differs from it.
    private let initialDraft: MethodDraft
    private let saveBrewMethodUseCase: SaveBrewMethodUseCase
    private let draftStore: MethodDraftStore
    private let compiler: MethodDraftCompiler
    private let analyticsTracker: AnalyticsTracker
    private let reviewPromptPolicy: ReviewPromptPolicy

    /// Timers run this many times faster in Try it.
    static let tryItSpeedUp: UInt = 10

    init(
        draft: MethodDraft,
        saveBrewMethodUseCase: SaveBrewMethodUseCase = SaveBrewMethodUseCaseImp(),
        draftStore: MethodDraftStore = MethodDraftStoreImp(),
        compiler: MethodDraftCompiler = MethodDraftCompiler(),
        analyticsTracker: AnalyticsTracker = AnalyticsTrackerImp(),
        reviewPromptPolicy: ReviewPromptPolicy = ReviewPromptPolicyImp.shared
    ) {
        self.draft = draft
        self.initialDraft = draft
        self.saveBrewMethodUseCase = saveBrewMethodUseCase
        self.draftStore = draftStore
        self.compiler = compiler
        self.analyticsTracker = analyticsTracker
        self.reviewPromptPolicy = reviewPromptPolicy
        self.preview = compiler.preview(for: draft)

        analyticsTracker.track(event: AnalyticsEvent(
            name: "create_method_opened",
            parameters: ["origin": MethodEditorViewModel.originName(draft.origin)]
        ))
    }

    var hasChanges: Bool {
        draft != initialDraft
    }

    var isEditingExisting: Bool {
        draft.editedMethodId != nil
    }

    var ratioText: String? {
        draft.referenceDose.ratioValue.map(CoffeeToWaterRatio.label(for:))
    }

    var writtenForText: String {
        var parts = ["\(Self.grams(draft.coffee)) g coffee", "\(Self.grams(draft.water)) g water"]
        if draft.addsIce, let ice = draft.ice {
            parts.append("\(Self.grams(ice)) g ice")
        }
        return parts.joined(separator: " \u{00B7} ")
    }

    static func grams(_ value: Double) -> Int {
        Int(value.rounded())
    }

    private func draftDidChange(from oldValue: MethodDraft) {
        preview = compiler.preview(for: draft)
        validationMessage = nil
        highlightedStepID = nil
        if draft != initialDraft {
            // Drafts save automatically: the single draft slot always holds the latest unsaved change.
            draftStore.save(draft)
        }
    }

    // MARK: Steps

    func index(ofStep id: UUID) -> Int? {
        draft.steps.firstIndex { $0.id == id }
    }

    /// A binding to one step. Any change to a step kept as stored makes it an ordinary editor step.
    func binding(forStep id: UUID) -> Binding<MethodStep>? {
        guard index(ofStep: id) != nil else { return nil }
        return Binding(
            get: { [weak self] in
                guard let self, let index = self.index(ofStep: id) else { return MethodStep(kind: .note) }
                return self.draft.steps[index]
            },
            set: { [weak self] newValue in
                guard let self, let index = self.index(ofStep: id) else { return }
                var step = newValue
                if step != self.draft.steps[index] {
                    step.legacy = nil
                }
                self.draft.steps[index] = step
            }
        )
    }

    func openPalette(at index: Int) {
        paletteInsertIndex = index
    }

    func insert(kind: MethodStepKind) {
        let index = min(paletteInsertIndex ?? draft.steps.count, draft.steps.count)
        paletteInsertIndex = nil
        var newDraft = draft
        if kind == .addIce, (newDraft.ice ?? 0) <= 0 {
            newDraft.ice = MethodDraft.defaultIce(forWater: newDraft.water)
        }
        let step = newDraft.newStep(kind: kind, at: index)
        newDraft.steps.insert(step, at: index)
        draft = newDraft
        analyticsTracker.track(event: AnalyticsEvent(name: "method_step_added", parameters: ["kind": kind.rawValue]))
        // Open the new step right away, so its fields can be filled in.
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(450))
            self?.editingStepID = step.id
        }
    }

    func duplicate(stepID: UUID) {
        guard let index = index(ofStep: stepID) else { return }
        let copy = draft.steps[index].duplicated()
        draft.steps.insert(copy, at: index + 1)
        editingStepID = nil
    }

    func delete(stepID: UUID) {
        guard let index = index(ofStep: stepID) else { return }
        let step = draft.steps.remove(at: index)
        editingStepID = nil
        deletedStep = (step, index)

        deletedStepDismissTask?.cancel()
        deletedStepDismissTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }
            self?.deletedStep = nil
        }
    }

    func undoDeleteStep() {
        guard let deletedStep else { return }
        deletedStepDismissTask?.cancel()
        draft.steps.insert(deletedStep.step, at: min(deletedStep.index, draft.steps.count))
        self.deletedStep = nil
    }

    func move(from source: IndexSet, to destination: Int) {
        draft.steps.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: Written for

    /// Whether changing the dose should ask about scaling the steps.
    var hasScalableSteps: Bool {
        draft.steps.contains { $0.legacy == nil && $0.amount?.grams != nil }
    }

    func updateDose(coffee: Double, water: Double, ice: Double?, scaleSteps: Bool) {
        draft = draft.updatingDose(coffee: coffee, water: water, ice: ice, scaleSteps: scaleSteps)
        analyticsTracker.track(event: AnalyticsEvent(name: "method_dose_changed", parameters: ["scaled": scaleSteps]))
    }

    // MARK: Footer fixes

    var hasPour: Bool {
        draft.steps.contains { $0.kind == .pour }
    }

    var lastPourIsRest: Bool {
        guard let last = draft.steps.last(where: { $0.kind == .pour }) else { return false }
        return last.legacy == nil && last.amount == .rest
    }

    func makeLastPourTheRest() {
        draft = draft.makingLastPourTheRest()
    }

    /// When the pours add up to more than the method's water: write the method for what is poured.
    func matchWaterToPoured() {
        draft.water = Double(preview.pouredWater)
    }

    func addPour() {
        paletteInsertIndex = draft.steps.count
        insert(kind: .pour)
    }

    // MARK: Close

    func close() {
        if hasChanges {
            isClosePromptPresented = true
        } else {
            didClose.send()
        }
    }

    /// Close and keep the draft; "Or, create your own" offers to continue it.
    func keepDraftAndClose() {
        draftStore.save(draft)
        didClose.send()
    }

    func discardAndClose() {
        draftStore.clear()
        analyticsTracker.track(event: AnalyticsEvent(name: "method_draft_discarded"))
        didClose.send()
    }

    // MARK: Save

    func save() {
        let issues = draft.validationIssues
        if let issue = issues.first {
            show(issue)
            analyticsTracker.track(event: AnalyticsEvent(
                name: "create_method_validated",
                parameters: ["result": "fail", "missing_field": MethodEditorViewModel.fieldName(issue)]
            ))
            return
        }
        analyticsTracker.track(event: AnalyticsEvent(name: "create_method_validated", parameters: ["result": "pass"]))

        if let editedId = draft.editedMethodId {
            let count = saveBrewMethodUseCase.recipesUsing(methodId: editedId).count
            if count > 0 {
                recipesUsingCount = count
                isSaveChoicePresented = true
                return
            }
            perform(mode: .updateEverywhere)
        } else {
            perform(mode: .asNew)
        }
    }

    func perform(mode: MethodSaveMode) {
        isSaveChoicePresented = false
        Task {
            do {
                let brewMethod = try await saveBrewMethodUseCase.save(draft, mode: mode)
                draftStore.clear()
                analyticsTracker.track(event: AnalyticsEvent(
                    name: "method_created",
                    parameters: [
                        "iced": brewMethod.isIcedBrew,
                        "step_count": draft.steps.count,
                        "origin": MethodEditorViewModel.originName(draft.origin),
                        "mode": mode == .asNew ? "new" : "update"
                    ]
                ))
                if mode == .asNew {
                    reviewPromptPolicy.record(.customMethodCreated)
                }
                didSave.send(brewMethod)
            } catch SaveBrewMethodUseCaseError.invalid(let issues) {
                if let issue = issues.first { show(issue) }
            } catch {
                validationMessage = "Couldn't save the method. Try again."
            }
        }
    }

    private func show(_ issue: MethodValidationIssue) {
        validationMessage = issue.message
        highlightedStepID = issue.stepNumber.flatMap { draft.steps[safe: $0 - 1]?.id }

        let flag: ReferenceWritableKeyPath<MethodEditorViewModel, Bool>
        switch issue {
        case .missingName: flag = \.animateName
        case .missingSteps: flag = \.animateSteps
        case .missingDose, .missingIce: flag = \.animateDose
        default: flag = \.animateSteps
        }
        self[keyPath: flag] = true
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(600))
            self?[keyPath: flag] = false
        }
    }

    // MARK: Try it

    func tryIt() {
        analyticsTracker.track(event: AnalyticsEvent(name: "method_try_it", parameters: ["step_count": draft.steps.count]))
        isTryItPresented = true
    }

    func dryRunRecipe() -> Recipe {
        compiler.dryRunRecipe(for: draft, timerSpeedUp: MethodEditorViewModel.tryItSpeedUp)
    }

    // MARK: Analytics names

    static func originName(_ origin: MethodDraftOrigin) -> String {
        switch origin {
        case .scratch: return "scratch"
        case .copy: return "copy"
        case .edit: return "edit"
        }
    }

    static func fieldName(_ issue: MethodValidationIssue) -> String {
        switch issue {
        case .missingName: return "method_title"
        case .missingSteps: return "instructions"
        case .missingDose: return "dose"
        case .missingIce: return "ice"
        case .emptyNote: return "note"
        case .missingAmount: return "amount"
        case .doneByTooEarly: return "done_by"
        case .timerTooLong: return "timer"
        }
    }
}
