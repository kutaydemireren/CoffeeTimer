//
//  MethodEditorMocks.swift
//  CoffeeTimerTests
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation
@testable import CoffeeTimer

final class MockSaveBrewMethodUseCase: SaveBrewMethodUseCase {
    var _recipesUsing: [Recipe] = []
    var _savedMethod: BrewMethod = .frenchPress(path: "custom-method://saved")
    var _error: Error?
    var saveCalls: [(draft: MethodDraft, mode: MethodSaveMode)] = []

    func recipesUsing(methodId: String) -> [Recipe] {
        _recipesUsing
    }

    func save(_ draft: MethodDraft, mode: MethodSaveMode) async throws -> BrewMethod {
        saveCalls.append((draft, mode))
        if let _error { throw _error }
        return _savedMethod
    }
}

final class MockMethodDraftStore: MethodDraftStore {
    var stored: MethodDraft?
    var saveCount = 0
    var clearCount = 0

    func load() -> MethodDraft? { stored }

    func save(_ draft: MethodDraft) {
        saveCount += 1
        stored = draft
    }

    func clear() {
        clearCount += 1
        stored = nil
    }
}

/// Keeps saved methods by id, like the real repository.
final class InMemoryBrewMethodRepository: BrewMethodRepository {
    var methods: [BrewMethod] = []

    func save(brewMethod: BrewMethod) async throws {
        if let index = methods.firstIndex(where: { $0.id == brewMethod.id }) {
            methods[index] = brewMethod
        } else {
            methods.append(brewMethod)
        }
    }

    func remove(brewMethod: BrewMethod) async throws {
        methods.removeAll { $0.id == brewMethod.id }
    }

    func getBrewMethods() async throws -> [BrewMethod] { methods }
}

/// Keeps saved instructions by identifier, like the real repository.
final class InMemoryRecipeInstructionsRepository: RecipeInstructionsRepository {
    var instructions: [RecipeInstructions] = []

    func save(instructions newInstructions: RecipeInstructions) async throws {
        if let index = instructions.firstIndex(where: { $0.identifier == newInstructions.identifier }) {
            instructions[index] = newInstructions
        } else {
            instructions.append(newInstructions)
        }
    }

    func fetchInstructions(for brewMethod: BrewMethod) async throws -> RecipeInstructions {
        guard let found = instructions.first(where: { $0.identifier == CustomMethodPathGenerator.parseID(path: brewMethod.path) }) else {
            throw RecipeInstructionsRepositoryError.invalidCustomMethod
        }
        return found
    }
}

/// Steps exactly as the old method editor on `main` saved them (a copy of the built-in V60), read back from a simulator.
func loadOldEditorV60Instructions() -> RecipeInstructions {
    let json = #"""
    {"identifier":"9FBAD219-2D16-4DD2-9155-020420F51061","steps":[
    {"skipMethod":"userInteractive","details":"","action":"message","requirement":{"type":"unknown"},"message":"Wet filter with hot water","startMethod":"userInteractive"},
    {"requirement":{"type":"unknown"},"startMethod":"userInteractive","amount":{"factorOf":"#total.coffee","factor":1,"adjustment":{"factor":0,"factorOf":"#current.coffee"},"type":"gram"},"action":"put","details":"Create a small hole in the middle","message":"Put all #current.amount g of coffee to brewer","ingredient":"coffee","skipMethod":"userInteractive"},
    {"skipMethod":"userInteractive","details":"Boil more than #total.water ml of water","action":"message","requirement":{"type":"unknown"},"message":"Boil water in your kettle","startMethod":"userInteractive"},
    {"requirement":{"type":"unknown"},"startMethod":"userInteractive","amount":{"factorOf":"#total.coffee","factor":2,"adjustment":{"factorOf":"#current.coffee","factor":0},"type":"millilitre"},"action":"put","details":"","message":"To bloom, gently pour #current.amount ml of water","ingredient":"water","skipMethod":"userInteractive"},
    {"skipMethod":"userInteractive","details":"Try to get it evenly mixed","action":"message","requirement":{"type":"unknown"},"message":"Throughly swirl the V60 brewer","startMethod":"userInteractive"},
    {"skipMethod":"auto","details":"","action":"pause","requirement":{"duration":{"type":"second","length":30},"type":"countdown"},"message":"Let it bloom for #current.duration seconds","startMethod":"auto"},
    {"requirement":{"duration":{"length":30,"type":"second"},"type":"countdown"},"startMethod":"userInteractive","amount":{"factorOf":"#total.water","factor":0.6,"adjustment":{"factorOf":"#current.water","factor":-1},"type":"millilitre"},"action":"put","details":"Remember to pour gently in cycles\nTotal: #current.water ml of water","message":"Pour #current.amount ml of water in ~30 seconds","ingredient":"water","skipMethod":"auto"},
    {"skipMethod":"auto","details":"","action":"pause","requirement":{"type":"countdown","duration":{"length":10,"type":"second"}},"message":"Pause for #current.duration seconds","startMethod":"auto"},
    {"startMethod":"auto","requirement":{"duration":{"type":"second","length":30},"type":"countdown"},"amount":{"type":"millilitre","factorOf":"#remaining.water","adjustment":{"factorOf":"#current.coffee","factor":0},"factor":1},"action":"put","details":"Pour in slower cycles during this phase\nTotal: #current.water ml of water","message":"Pour the remaining #current.amount ml of water in ~30 seconds","ingredient":"water","skipMethod":"auto"},
    {"startMethod":"userInteractive","skipMethod":"userInteractive","message":"Your brew is ready","requirement":{"type":"unknown"},"details":"Let it cool for a minute, then enjoy your sip!","action":"message"}
    ]}
    """#
    return try! JSONDecoder().decode(RecipeInstructions.self, from: Data(json.utf8))
}

extension BrewMethod {
    /// A method saved by the old editor: no reference dose, the fixed hot ratios.
    static var oldCustom: BrewMethod {
        BrewMethod(
            id: "9FBAD219-2D16-4DD2-9155-020420F51061",
            iconName: "recipe-profile-gooseneck-kettle",
            title: "Old V60 Mine",
            path: "custom-method://9FBAD219-2D16-4DD2-9155-020420F51061",
            isIcedBrew: false,
            cupsCount: CupsCount(minimum: 1, maximum: nil),
            ratios: StaticCoffeetoWaterRatioGenerator.hotBrew(),
            info: InfoModel(title: "Old V60 Mine", body: "")
        )
    }
}
