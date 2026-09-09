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

    init(modelContext: ModelContext, watchConnector: WatchConnector = WatchConnector()) {
        self.modelContext = modelContext
        self.watchConnector = watchConnector

        watchConnector.onReceivePayload = { [weak self] payload in
            guard let self else { return .success(()) }
            return self.addMatch(from: payload)
        }
    }

    private func addMatch(from payload: MatchGPSPayload) -> Result<Void, Error> {
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

        do {
            try modelContext.save()
            return .success(())
        } catch {
            modelContext.delete(item)
            return .failure(error)
        }
    }
}
