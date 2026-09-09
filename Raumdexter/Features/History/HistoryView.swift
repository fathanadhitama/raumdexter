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

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                AppTheme.backgroundGradient
                    .frame(height: 260)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        titleHeader

                        if matches.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 18) {
                                ForEach(matches) { match in
                                    NavigationLink(value: match) {
                                        matchCard(match)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 110)
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
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "History")

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("My Matches")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)

//                Text("\(matches.count)")
//                    .font(.system(size: 13, weight: .bold, design: .rounded))
//                    .foregroundColor(AppTheme.accent)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 4)
//                    .background(Capsule().fill(AppTheme.accentSoft))
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Match Card

    private func matchCard(_ match: MatchHistoryItem) -> some View {
        VStack(spacing: 14) {
            HeatmapPlaceholderView(points: match.heatmapPoints)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(match.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .lineLimit(1)

                    Text(match.dateText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    miniStat(value: "\(match.goals)", label: "G")
                    miniStat(value: "\(match.assists)", label: "A")
                    miniStat(
                        value: String(match.distanceText.split(separator: " ").first ?? "-"),
                        label: String(match.distanceText.split(separator: " ").last?.uppercased() ?? "-")
                    )
                }
            }
        }
        .padding(14)
        .cardSurface(cornerRadius: 24)
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.tertiaryText)
        }
        .frame(minWidth: 34)
        .padding(6)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(AppTheme.surfaceElevated))
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sportscourt")
                .font(.system(size: 38, weight: .light))
                .foregroundColor(AppTheme.tertiaryText)

            Text("Belum ada match tersimpan")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)

            Text("Selesaikan satu match dari Apple Watch untuk melihat riwayatnya di sini.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 28)
        .cardSurface(cornerRadius: 24)
    }
}

#Preview {
    let mockMatches: [MatchHistoryItem] = [
        MatchHistoryItem(
            title: "Sunday Match",
            date: Date(),
            goals: 2,
            assists: 1,
            totalDistanceMeters: 3420,
            heatmapPoints: GPSPoint.mockMatchPoints(count: 300)
        ),
        MatchHistoryItem(
            title: "Friday Night",
            date: Date().addingTimeInterval(-604_800),
            goals: 1,
            assists: 2,
            totalDistanceMeters: 2870,
            heatmapPoints: GPSPoint.mockMatchPoints(count: 220)
        ),
        MatchHistoryItem(
            title: "Casual Game",
            date: Date().addingTimeInterval(-1_209_600),
            goals: 0,
            assists: 1,
            totalDistanceMeters: 999,
            heatmapPoints: GPSPoint.mockMatchPoints(count: 150)
        )
    ]

    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: MatchHistoryItem.self,
        GPSPoint.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    for match in mockMatches {
        container.mainContext.insert(match)
    }

    return HistoryView()
        .modelContainer(container)
}
