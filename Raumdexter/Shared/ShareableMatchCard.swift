//
//  ShareableMatchCard.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 04/09/26.
//

import SwiftUI

struct ShareableMatchCard: View {
    let match: MatchHistoryItem

    var body: some View {
        VStack(spacing: 16) {
            Text("Raumdexter")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.accentGreen)

            Text(match.title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Text(match.dateText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.secondaryText)

            HeatmapPlaceholderView(points: match.heatmapPoints)
        }
//        .padding(24)
        .frame(width: 380)
//        .background(.red)
    }
}

#Preview {
    let mockMatch = MatchHistoryItem(
        title: "Sunday League Match 1",
        date: Date(),
        goals: 0,
        assists: 1,
        totalDistanceMeters: 1293,
        heatmapPoints: GPSPoint.mockMatchPoints(count: 100),
    )
    
    ShareableMatchCard(match: mockMatch)
        .background(.black)
}
