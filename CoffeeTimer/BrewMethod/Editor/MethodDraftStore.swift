//
//  MethodDraftStore.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 24/11/2026.
//

import Foundation

/// Keeps one unsaved method draft, so work survives closing the editor or the app.
///
/// There is a single slot. The editor writes to it whenever the draft changes and clears it on save or discard.
protocol MethodDraftStore {
    func load() -> MethodDraft?
    func save(_ draft: MethodDraft)
    func clear()
}

struct MethodDraftStoreImp: MethodDraftStore {
    static let key = "methodEditorDraft"

    private let storage: Storage

    init(storage: Storage = StorageImp(userDefaults: .standard)) {
        self.storage = storage
    }

    func load() -> MethodDraft? {
        storage.load(forKey: MethodDraftStoreImp.key)
    }

    func save(_ draft: MethodDraft) {
        storage.save(draft, forKey: MethodDraftStoreImp.key)
    }

    func clear() {
        storage.save(Optional<MethodDraft>.none, forKey: MethodDraftStoreImp.key)
    }
}
