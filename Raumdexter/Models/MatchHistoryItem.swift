//
//  MatchHistoryItem.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//
import SwiftData
import Foundation

@Model
final class MatchHistoryItem {
    var title: String
    var date: Date
    var goals: Int = 0
    var assists: Int = 0
    var totalDistanceMeters: Double = 0

    @Relationship(deleteRule: .cascade)
    var heatmapPoints: [GPSPoint]

    init(title: String, date: Date, goals: Int, assists: Int, totalDistanceMeters: Double, heatmapPoints: [GPSPoint]) {
        self.title = title
        self.date = date
        self.goals = goals
        self.assists = assists
        self.totalDistanceMeters = totalDistanceMeters
        self.heatmapPoints = heatmapPoints
    }

    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }

    var distanceText: String {
        String(format: "%.2f km", totalDistanceMeters / 1000)
    }

    var durationText: String {
        let timestamps = heatmapPoints.map(\.timestamp)
        guard let first = timestamps.min(), let last = timestamps.max(), last > first else { return "-" }
        let minutes = Int(last.timeIntervalSince(first) / 60)
        return "\(minutes) min"
    }
}
