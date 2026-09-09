//
//  ShareableMatchCard.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 04/09/26.
//

import SwiftUI

/// Kartu yang di-render jadi gambar buat dibagikan (Instagram Story, Photos, dll).
/// Background-nya dibatasi ke shape membulat supaya sudutnya tetap transparan di PNG.
struct ShareableMatchCard: View {
    let match: MatchHistoryItem

    var body: some View {
        VStack(spacing: 18) {
            header
            HeatmapPlaceholderView(points: match.heatmapPoints)
            statsRow
        }
        .padding(22)
        .frame(width: 380)
//        .background(
//            RoundedRectangle(cornerRadius: 30, style: .continuous)
//                .fill(AppTheme.background)
//        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(match.title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(2)

                Text(match.dateText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.tertiaryText)
            }

            Spacer(minLength: 12)

            Text("RAUMDEXTER")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1.4)
                .foregroundColor(AppTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(AppTheme.accentSoft))
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statColumn(value: "\(match.goals)", label: "Goals")
            divider
            statColumn(value: "\(match.assists)", label: "Assists")
            divider
            statColumn(value: match.distanceText, label: "Distance")
            divider
            statColumn(value: match.durationText, label: "Duration")
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.surface)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(AppTheme.divider)
            .frame(width: 1, height: 24)
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let mockMatch = MatchHistoryItem(
        title: "Sunday League Match 1",
        date: Date(),
        goals: 2,
        assists: 1,
        totalDistanceMeters: 5293,
        heatmapPoints: GPSPoint.mockMatchPoints(count: 300)
    )

    ShareableMatchCard(match: mockMatch)
        .padding(30)
        .background(Color.gray)
}
