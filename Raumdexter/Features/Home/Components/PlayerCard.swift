//
//  PlayerCard.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI

/// Header hero di Home: identitas pemain di atas gradient, foto bleeding ke kanan.
struct PlayerCard: View {
    var viewModel: HomeViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                jerseyChip

                Text(viewModel.player.name.uppercased())
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)

//                SectionLabel(text: "Player", color: AppTheme.secondaryText)
            }
            .padding(.bottom, 58)

            Spacer(minLength: 8)

            playerPhoto
        }
        .padding(.leading, 20)
        .padding(.top, 16)
    }

    private var jerseyChip: some View {
        Text("#\(viewModel.player.jerseyNumber)")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(AppTheme.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(AppTheme.accentSoft))
            .overlay(Capsule().stroke(AppTheme.accent.opacity(0.35), lineWidth: 1))
    }

    private var playerPhoto: some View {
        Group {
            if UIImage(named: viewModel.player.photoName) != nil {
                Image(viewModel.player.photoName)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "figure.soccer")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(AppTheme.accent.opacity(0.5))
                    .padding(30)
            }
        }
        .frame(width: 215, height: 255, alignment: .bottom)
        .padding(.bottom, 26)
    }
}

#Preview {
    ZStack {
        AppTheme.heroGradient.ignoresSafeArea()
        PlayerCard(viewModel: HomeViewModel())
    }
}
