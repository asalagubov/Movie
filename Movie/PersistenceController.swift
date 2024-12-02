//
//  PersistenceController.swift
//  Movie
//
//  Created by Aleksandr Salagubov on 01.12.2024.
//


import SwiftData

@MainActor
class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    private init() {
        container = try! ModelContainer(for: LocalMovie.self)
    }

    var mainContext: ModelContext {
        container.mainContext
    }
}
