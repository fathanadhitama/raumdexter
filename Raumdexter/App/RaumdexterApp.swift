//
//  RaumdexterApp.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import SwiftData

@main
struct RaumdexterApp: App {
    let modelContainer: ModelContainer
    @StateObject private var ingestor: MatchIngestor

    init() {
        do {
            let container = try ModelContainer(
                for: MatchHistoryItem.self,
                GPSPoint.self,
                PlayerProfile.self
            )

            modelContainer = container
            _ingestor = StateObject(
                wrappedValue: MatchIngestor(modelContext: container.mainContext)
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
