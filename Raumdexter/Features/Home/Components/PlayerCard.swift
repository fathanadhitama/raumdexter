//
//  PlayerCard.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import SwiftData

/// Header hero di Home: identitas pemain di atas gradient, foto bleeding ke kanan.
struct PlayerCard: View {
    @Query private var profiles: [PlayerProfile]

    let onEdit: () -> Void

    private var profile: PlayerProfile? { profiles.first }
    private var displayName: String { profile?.name ?? PlayerProfile.defaultName }
    private var jerseyNumber: Int { profile?.jerseyNumber ?? PlayerProfile.defaultJerseyNumber }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                jerseyChip

                Text(displayName.uppercased())
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)

                editButton
            }
            .padding(.bottom, 44)

            Spacer(minLength: 8)

            playerPhoto
        }
        .padding(.leading, 20)
        .padding(.top, 16)
    }

    private var jerseyChip: some View {
        Text("#\(jerseyNumber)")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(AppTheme.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(AppTheme.accentSoft))
            .overlay(Capsule().stroke(AppTheme.accent.opacity(0.35), lineWidth: 1))
    }

    private var editButton: some View {
        Button(action: onEdit) {
            HStack(spacing: 5) {
                Image(systemName: "pencil")
                    .font(.system(size: 10, weight: .bold))
                Text("Edit Profile")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(AppTheme.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(Color.white.opacity(0.08)))
            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Edit player profile")
    }

    private var playerPhoto: some View {
        Group {
            if let data = profile?.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 168, height: 168)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .overlay(Circle().stroke(.white.opacity(0.01), lineWidth: 0.1))
            } else {
                Image(systemName: "figure.soccer")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(AppTheme.accent.opacity(0.5))
                    .padding(40)
                    .frame(width: 200, height: 210)
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 34)
    }
}

#Preview {
    ZStack {
        AppTheme.heroGradient.ignoresSafeArea()
        PlayerCard(onEdit: {})
    }
    .modelContainer(for: [MatchHistoryItem.self, GPSPoint.self, PlayerProfile.self], inMemory: true)
}
