//
//  HistoryView.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \MatchHistoryItem.date, order: .reverse) private var matches: [MatchHistoryItem]
//    let matches = [
//        MatchHistoryItem(
//            title: "Sunday League Match 1",
//            date: Date(),
//            goals: 0,
//            assists: 1,
//            totalDistanceMeters: 1230,
//            heatmapPoints: GPSPoint.mockMatchPoints(count: 100)
//        ),
//        MatchHistoryItem(
//            title: "Sunday League Match 2",
//            date: Date(),
//            goals: 3,
//            assists: 1,
//            totalDistanceMeters: 972,
//            heatmapPoints: GPSPoint.mockMatchPoints(count: 270)
//        ),
//        MatchHistoryItem(
//            title: "Sunday League Match 3",
//            date: Date(),
//            goals: 5,
//            assists: 2,
//            totalDistanceMeters: 1293,
//            heatmapPoints: GPSPoint.mockMatchPoints(count: 190)
//        )
//    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    titleHeader

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            ForEach(matches) { match in
                                NavigationLink(value: match) {
                                    matchCard(match)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationDestination(for: MatchHistoryItem.self) { match in
                MatchDetailView(match: match)
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Header

    private var titleHeader: some View {
        Text("My Matches")
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(AppTheme.primaryText)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    // MARK: - Match Card

    private func matchCard(_ match: MatchHistoryItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.cardBackground)

                HeatmapPlaceholderView(points: match.heatmapPoints)
                    .padding(16)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(match.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                Text(match.dateText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(.leading, 2)
        }
    }
}

#Preview {
//    let container: ModelContainer
//    do {
//        container = try ModelContainer(
//            for: MatchHistoryItem.self, GPSPoint.self,
//            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//        )
//    } catch {
//        fatalError("Gagal bikin preview container: \(error)")
//    }
//
//    let df = DateFormatter()
//    df.dateFormat = "dd-MM-yyyy"
//
//    let mockMatches = [
//        MatchHistoryItem(
//            title: "Sunday League Match 1",
//            date: df.date(from: "09-04-2026") ?? Date(),
//            goals: 0,
//            assists: 1,
//            totalDistanceMeters: 1230,
//            heatmapPoints: GPSPoint.mockMatchPoints(count: 100)
//        ),
//        MatchHistoryItem(
//            title: "Sunday League Match 2",
//            date: df.date(from: "16-04-2026") ?? Date(),
//            goals: 3,
//            assists: 1,
//            totalDistanceMeters: 972,
//            heatmapPoints: GPSPoint.mockMatchPoints(count: 270)
//        ),
//        MatchHistoryItem(
//            title: "Sunday League Match 3",
//            date: df.date(from: "23-04-2026") ?? Date(),
//            goals: 5,
//            assists: 2,
//            totalDistanceMeters: 1293,
//            heatmapPoints: GPSPoint.mockMatchPoints(count: 190)
//        )
//    ]
//    mockMatches.forEach { container.mainContext.insert($0) }

    return HistoryView()
//        .modelContainer(container)
}
