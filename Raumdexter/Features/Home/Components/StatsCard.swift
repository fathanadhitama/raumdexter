//
//  StatsCard.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 07/09/26.
//

import SwiftUI
import SwiftData

/// Kartu ringkasan statistik karier — mengambang di atas hero header.
struct StatsCard: View {
    @Query private var matches: [MatchHistoryItem]

    private var matchCountText: String { "\(matches.count)" }
    private var goalCountText: String { "\(matches.map(\.goals).reduce(0, +))" }
    private var assistCountText: String { "\(matches.map(\.assists).reduce(0, +))" }
    private var avgDistanceText: String {
        guard !matches.isEmpty else { return "0.0" }
        let totalMeters = matches.map(\.totalDistanceMeters).reduce(0, +)
        let avgKm = (totalMeters / Double(matches.count)) / 1000
        return String(format: "%.1f", avgKm)
    }

    var body: some View {
        HStack(spacing: 0) {
            statColumn(value: matchCountText, label: "Matches")
            separator
            statColumn(value: goalCountText, label: "Goals")
            separator
            statColumn(value: assistCountText, label: "Assists")
            separator
            statColumn(value: avgDistanceText, label: "km/match")
        }
        .padding(.vertical, 18)
        .background(AppTheme.accentGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: AppTheme.accent.opacity(0.28), radius: 20, x: 0, y: 10)
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.white.opacity(0.18))
            .frame(width: 1, height: 28)
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatsCard()
        .padding(20)
        .background(AppTheme.background)
        .modelContainer(for: [MatchHistoryItem.self, GPSPoint.self], inMemory: true)
}
