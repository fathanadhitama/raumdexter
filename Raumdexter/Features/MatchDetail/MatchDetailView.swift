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
        .alert("Delete Match?", isPresented: $viewModel.isDeleteConfirmationPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.delete(match, context: modelContext)
                dismiss()
            }
        } message: {
            Text("“\(match.title)” and all of its data will be deleted.")
        }
        .alert("Change Match Title", isPresented: $viewModel.isRenamePresented) {
            TextField("Match Title", text: $viewModel.draftTitle)
                .textInputAutocapitalization(.words)

            Button("Cancel", role: .cancel) {}
            Button("Save") {
                viewModel.commitRename(match, context: modelContext)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: match.dateText)

            Button(action: { viewModel.startRename(match) }) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(match.title)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.leading)

                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change match name")
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

                Text("\(match.heatmapPoints.count) GPS points")
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
                onSave: { await viewModel.saveShareImage() },
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
    .modelContainer(for: [MatchHistoryItem.self, GPSPoint.self, PlayerProfile.self], inMemory: true)
}
