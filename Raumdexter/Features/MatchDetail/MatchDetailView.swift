//
//  MatchDetailView.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import SwiftData

struct MatchDetailView: View {
    let match: MatchHistoryItem

    @StateObject private var viewModel = MatchDetailViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            AppTheme.backgroundGradient
                .frame(height: 300)
                .frame(maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    titleBlock
                    heatmapCard
                    statsGrid
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 110)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: { viewModel.share(match) },
                    label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.isSharePresented) { shareSheet }
        .sheet(isPresented: $viewModel.isActivityPresented) {
            if let image = viewModel.shareImage {
                ActivityView(activityItems: [image])
            }
        }
        .confirmationDialog(
            "Hapus match ini?",
            isPresented: $viewModel.isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Hapus", role: .destructive) {
                viewModel.delete(match, context: modelContext)
                dismiss()
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Data GPS dan statistik match ini akan dihapus permanen.")
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: match.dateText)

            Text(match.title)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Heatmap

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeatmapPlaceholderView(points: match.heatmapPoints)

            HStack(spacing: 6) {
                SectionLabel(text: "Own goal", size: 9)
                Image(systemName: "arrow.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(AppTheme.tertiaryText)
                SectionLabel(text: "Attacking", size: 9)

                Spacer()

                Text("\(match.heatmapPoints.count) titik GPS")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.tertiaryText)
            }
        }
        .padding(14)
        .cardSurface(cornerRadius: 24)
    }

    // MARK: - Stats

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(text: "Match Stats")

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    statCard(value: "\(match.goals)", label: "Goals", icon: "soccerball")
                    statCard(value: "\(match.assists)", label: "Assists", icon: "a.circle")
                }
                HStack(spacing: 12) {
                    statCard(value: match.distanceText, label: "Distance", icon: "figure.run")
                    statCard(value: match.durationText, label: "Duration", icon: "clock.fill")
                }
            }
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.accent)
                .frame(width: 32, height: 32)
                .background(Circle().fill(AppTheme.accentSoft))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardSurface(cornerRadius: 20)
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(
                action: { viewModel.share(match) },
                label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Share Match")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            )

            Button(
                action: { viewModel.isDeleteConfirmationPresented = true },
                label: {
                    Text("Delete Match")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(AppTheme.danger.opacity(0.1))
                        )
                }
            )
        }
        .padding(.top, 4)
    }

    // MARK: - Share

    @ViewBuilder
    private var shareSheet: some View {
        if let image = viewModel.shareImage {
            SharePreviewView(
                image: image,
                onSave: {
                    Task { _ = await viewModel.saveShareImage() }
                },
                onInstagram: {
                    UIPasteboard.general.setData(
                        image.pngData() ?? Data(),
                        forPasteboardType: "com.instagram.sharedSticker.backgroundImage"
                    )
                    guard let url = URL(string: "instagram-stories://share?source_application=\(instagramAppID)") else { return }
                    UIApplication.shared.open(url)
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        MatchDetailView(
            match: MatchHistoryItem(
                title: "Sunday League Match 1",
                date: Date(),
                goals: 2,
                assists: 1,
                totalDistanceMeters: 5320,
                heatmapPoints: GPSPoint.mockMatchPoints(count: 400)
            )
        )
    }
    .modelContainer(for: [MatchHistoryItem.self, GPSPoint.self], inMemory: true)
}
