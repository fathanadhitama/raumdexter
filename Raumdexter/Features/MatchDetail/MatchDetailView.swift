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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heatmapCard
                    statsGrid
                    deleteButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(match.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: { viewModel.share(match) },
                    label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppTheme.accentGreen)
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.isSharePresented) {
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

    // MARK: - Heatmap

    private var heatmapCard: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.cardBackground)
                    .frame(height: 280)

                HeatmapPlaceholderView(points: match.heatmapPoints)
                    .padding(16)
            }

            Text(match.dateText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.secondaryText)
        }
    }

    // MARK: - Stats

    private var statsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statCard(value: "\(match.goals)", label: "Goals", icon: "soccerball")
                statCard(value: "\(match.assists)", label: "Assists", icon: "hand.point.up.left.fill")
            }
            HStack(spacing: 12) {
                statCard(value: match.distanceText, label: "Distance", icon: "figure.run")
                statCard(value: match.durationText, label: "Duration", icon: "clock.fill")
            }
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.accentGreen)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(
            action: { viewModel.isDeleteConfirmationPresented = true },
            label: {
                Text("Delete Match")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.red.opacity(0.12))
                    )
            }
        )
        .padding(.top, 8)
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
