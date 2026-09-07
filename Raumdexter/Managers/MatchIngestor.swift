//
//  MatchIngestor.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 03/09/26.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class MatchIngestor: ObservableObject {
    private let watchConnector: WatchConnector
    private let modelContext: ModelContext
    private var cancellables = Set<AnyCancellable>()

    init(modelContext: ModelContext, watchConnector: WatchConnector = WatchConnector()) {
        self.modelContext = modelContext
        self.watchConnector = watchConnector

        watchConnector.$latestPayload
            .compactMap { $0 }
            .sink { [weak self] payload in
                self?.addMatch(from: payload)
            }
            .store(in: &cancellables)
    }

    private func addMatch(from payload: MatchGPSPayload) {
        let points = GPSPoint.calibrated(samples: payload.samples, center: payload.center, ownGoal: payload.ownGoal)
        let count = (try? modelContext.fetchCount(FetchDescriptor<MatchHistoryItem>())) ?? 0
        let item = MatchHistoryItem(
            title: "Match \(count + 1)",
            date: Date(),
            goals: payload.goals,
            assists: payload.assists,
            totalDistanceMeters: payload.distanceMeters,
            heatmapPoints: points
        )
        modelContext.insert(item)
        try? modelContext.save()
    }
}
