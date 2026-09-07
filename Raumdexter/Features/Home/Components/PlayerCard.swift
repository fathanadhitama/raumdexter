//
//  PlayerCard.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import SwiftData

struct PlayerCard: View {
    var viewModel: HomeViewModel
    
    @Query private var matches: [MatchHistoryItem]
    private var matchCountText: String { "\(matches.count)" }
    private var goalCountText: String { "\(matches.map(\.goals).reduce(0, +))" }
    private var assistCountText: String { "\(matches.map(\.assists).reduce(0, +))" }
    private var avgDistanceText: String {
        guard !matches.isEmpty else { return "0.0 km" }
        let totalMeters = matches.map(\.totalDistanceMeters).reduce(0, +)
        let avgKm = (totalMeters / Double(matches.count)) / 1000
        return String(format: "%.1f km", avgKm)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.player.name)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
 
                    Text("\(viewModel.player.jerseyNumber)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.accentGreen)
                }
//                .background(.yellow)
 
                Spacer()
 
                playerPhoto
//                    .background(.blue)
                
                Spacer()
                
                VStack {}
                .frame(width: 100, height: 100)
//                .background(Color.blue)
            }
//            .background(.red)
 
            Divider()
                .background(AppTheme.divider)
//                .padding(.vertical, 16)
 
            HStack(spacing: 0) {
                statItem(value: matchCountText, label: "Match")
                statItem(value: goalCountText, label: "Goal")
                statItem(value: assistCountText, label: "Assist")
                statItem(value: avgDistanceText, label: "Avg. Distance", small: true)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.accentGreen.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var playerPhoto: some View {
        Group {
            if UIImage(named: viewModel.player.photoName) != nil {
                Image(viewModel.player.photoName)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "figure.soccer")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(AppTheme.accentGreen)
                    .padding(20)
            }
        }
        .frame(width: 100, height: 130)
//        .background(.red)
    }
    
    private func statItem(value: String, label: String, small: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: small ? 16 : 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
}

#Preview {
    PlayerCard(viewModel: HomeViewModel())
}
