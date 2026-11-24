//
//  MethodDraftFactory.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation

/// Opens methods in the editor and turns a finished draft back into a method.
struct MethodDraftFactory {
    var mapper: MethodStepMapper = MethodStepMapperImp()

    /// Ice share of the total liquid that iced methods without a reference dose use (see `CreateContextToInputMapperImp`).
    private static let defaultIceShareOfTotal = 0.4

    /// The dose a method is shown at: its own reference dose, or 15 g / 250 g for built-in and older methods.
    ///
    /// Iced methods without a reference dose get ice that keeps today's 40% share of the total liquid.
    static func dose(for brewMethod: BrewMethod) -> ReferenceDose {
        if let referenceDose = brewMethod.referenceDose {
            return referenceDose
        }
        guard brewMethod.isIcedBrew else {
            return ReferenceDose(coffee: MethodDraft.defaultCoffee, water: MethodDraft.defaultWater)
        }
        let iceToWater = defaultIceShareOfTotal / (1 - defaultIceShareOfTotal)
        return ReferenceDose(
            coffee: MethodDraft.defaultCoffee,
            water: MethodDraft.defaultWater,
            ice: (MethodDraft.defaultWater * iceToWater).rounded()
        )
    }

    static func isOwn(_ brewMethod: BrewMethod) -> Bool {
        CustomMethodPathGenerator.parseID(path: brewMethod.path) != nil
    }

    /// "Make it mine": a new method with a copy of the steps.
    ///
    /// `existingTitles` are the titles of the methods the user already has, so a second copy
    /// of the same method gets a different default name ("My V60 2").
    func draft(copying brewMethod: BrewMethod, instructions: RecipeInstructions, existingTitles: [String] = []) -> MethodDraft {
        var draft = draft(from: brewMethod, instructions: instructions)
        draft.name = MethodDraftFactory.copyName(for: brewMethod, among: existingTitles)
        draft.origin = .copy(of: brewMethod.id)
        return draft
    }

    /// The default name of a copy: "My V60" for a built-in method, "V60 Mine copy" for an own one.
    /// When that name is taken, it gets the first free number from 2: "My V60 2", "My V60 3".
    /// Names are compared ignoring case and surrounding spaces.
    static func copyName(for brewMethod: BrewMethod, among existingTitles: [String]) -> String {
        let base = isOwn(brewMethod) ? "\(brewMethod.title) copy" : "My \(brewMethod.title)"
        let taken = Set(existingTitles.map(normalizedTitle))
        guard taken.contains(normalizedTitle(base)) else { return base }

        var number = 2
        while taken.contains(normalizedTitle("\(base) \(number)")) {
            number += 1
        }
        return "\(base) \(number)"
    }

    private static func normalizedTitle(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Edit: the same method, saved under the same id unless the user picks "Save as new".
    func draft(editing brewMethod: BrewMethod, instructions: RecipeInstructions) -> MethodDraft {
        var draft = draft(from: brewMethod, instructions: instructions)
        draft.origin = .edit(BrewMethodSnapshot(brewMethod: brewMethod))
        return draft
    }

    private func draft(from brewMethod: BrewMethod, instructions: RecipeInstructions) -> MethodDraft {
        let dose = MethodDraftFactory.dose(for: brewMethod)
        let stages = MethodDraftCompiler.evaluate(steps: instructions.steps, dose: dose)

        let steps = instructions.steps.enumerated().map { index, instructionStep -> MethodStep in
            var step = mapper.methodStep(from: instructionStep, dose: dose)
            if step.legacy != nil, step.kind.hasAmount {
                // Start the step sheet from what the step pours at this dose.
                step.amount = .add(Double(MethodDraftFactory.grams(of: stages[index]) ?? 0))
            }
            return step
        }

        return MethodDraft(
            name: brewMethod.title,
            iconName: brewMethod.iconName.isEmpty ? MethodDraft.kettleIcon : brewMethod.iconName,
            coffee: dose.coffee,
            water: dose.water,
            ice: dose.ice,
            steps: steps,
            origin: .scratch
        )
    }

    private static func grams(of stage: BrewStage?) -> UInt? {
        switch stage?.action {
        case .pourWater(let amount)?, .putCoffee(let amount)?, .putIce(let amount)?:
            return amount.amount
        default:
            return nil
        }
    }

    /// The method to save. `id` is the edited method's id for "Update everywhere", or a new one.
    func brewMethod(from draft: MethodDraft, id: String) -> BrewMethod {
        let isIced = draft.addsIce
        let title = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)

        var cupsCount = CupsCount.unlimited
        var ratios = isIced ? StaticCoffeetoWaterRatioGenerator.icedBrew() : StaticCoffeetoWaterRatioGenerator.hotBrew()
        var info = InfoModel(title: title, body: "")
        if case .edit(let snapshot) = draft.origin, snapshot.id == id {
            cupsCount = CupsCount(minimum: snapshot.cupsMinimum, maximum: snapshot.cupsMaximum)
            if !snapshot.ratios.isEmpty {
                ratios = snapshot.ratios.map { CoffeeToWaterRatio(id: $0.id ?? "", value: $0.value ?? 0, title: $0.title ?? "") }
            }
            info = InfoModel(title: title, body: snapshot.infoBody)
        }

        return BrewMethod(
            id: id,
            iconName: draft.iconName,
            title: title,
            path: CustomMethodPathGenerator.generate(id: id),
            isIcedBrew: isIced,
            cupsCount: cupsCount,
            ratios: ratios,
            info: info,
            referenceDose: ReferenceDose(coffee: draft.coffee, water: draft.water, ice: isIced ? draft.ice : nil)
        )
    }
}
