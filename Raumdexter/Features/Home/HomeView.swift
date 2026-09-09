//
//  HomeView.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @Query(sort: \MatchHistoryItem.date, order: .reverse) private var matches: [MatchHistoryItem]

    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var latestMatch: MatchHistoryItem? { matches.first }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroHeader

                        VStack(spacing: 28) {
                            StatsCard()
                                .padding(.top, -34)

                            latestMatchSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                    }
                }
            }
            .navigationDestination(for: MatchHistoryItem.self) { match in
                MatchDetailView(match: match)
            }
            .sheet(isPresented: $viewModel.isSharePresented) {
                shareSheet
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Hero

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            AppTheme.heroGradient

            Circle()
                .fill(AppTheme.accent.opacity(0.35))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: 90, y: -60)

            PlayerCard(viewModel: viewModel)
        }
        .frame(height: 330)
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 32,
                bottomTrailingRadius: 32,
                style: .continuous
            )
        )
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Latest Match

    private var latestMatchSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    SectionLabel(text: "Latest Match")
                    Text(latestMatch?.title ?? "Belum ada match")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primaryText)
                }

                Spacer()

                if latestMatch != nil {
                    shareButton
                }
            }

            latestMatchCardLink
        }
    }

    private var shareButton: some View {
        Button(
            action: { viewModel.shareLatestMatch(latestMatch) },
            label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppTheme.accentSoft))
                    .overlay(Circle().stroke(AppTheme.accent.opacity(0.3), lineWidth: 1))
            }
        )
    }

    @ViewBuilder
    private var latestMatchCardLink: some View {
        if let latestMatch {
            NavigationLink(value: latestMatch) {
                latestMatchCard(latestMatch)
            }
            .buttonStyle(.plain)
        } else {
            emptyMatchCard
        }
    }

    private func latestMatchCard(_ match: MatchHistoryItem) -> some View {
        VStack(spacing: 16) {
            HeatmapPlaceholderView(points: match.heatmapPoints)

            HStack(spacing: 10) {
                metricChip(icon: "soccerball", value: "\(match.goals)")
                metricChip(icon: "a.circle", value: "\(match.assists)")
                metricChip(icon: "figure.run", value: match.distanceText)

                Spacer()

                Text(match.dateText)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.tertiaryText)
            }
        }
        .padding(14)
        .cardSurface(cornerRadius: 24)
    }

    private var emptyMatchCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(AppTheme.tertiaryText)

            Text("Mulai match dari Apple Watch")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)

            Text("Heatmap kamu bakal muncul di sini setelah match selesai.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .padding(.horizontal, 24)
        .cardSurface(cornerRadius: 24)
    }

    private func metricChip(icon: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.accent)
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(AppTheme.surfaceElevated))
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
                        forPasteboardType: "com.instagram.sharedSticker.stickerImage"
                    )
                    guard let url = URL(string: "instagram-stories://share?source_application=\(instagramAppID)") else { return }
                    UIApplication.shared.open(url)
                }
            )
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [MatchHistoryItem.self, GPSPoint.self], inMemory: true)
}
