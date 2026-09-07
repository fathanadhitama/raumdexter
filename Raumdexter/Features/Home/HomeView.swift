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
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            PlayerCard(viewModel: viewModel)
                            latestMatchHeader
                            latestMatchCardLink
    //                        startNewMatchButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100) // ruang untuk bottom bar
                    }
                }
            }
            .navigationDestination(for: MatchHistoryItem.self) { match in
                MatchDetailView(match: match)
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
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Latest Match Header

    private var latestMatchHeader: some View {
        HStack {
            Text("Latest Match")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.primaryText)

            Spacer()

            Button(
                action: { viewModel.shareLatestMatch(latestMatch) },
                label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.accentGreen)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(AppTheme.accentGreen, lineWidth: 1.5)
                    )
                }
            )
        }
    }

    // MARK: - Latest Match Card (heatmap)

    @ViewBuilder
    private var latestMatchCardLink: some View {
        if let latestMatch {
            NavigationLink(value: latestMatch) {
                latestMatchCard
            }
            .buttonStyle(.plain)
        } else {
            latestMatchCard
        }
    }

    private var latestMatchCard: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.cardBackground)

                HeatmapPlaceholderView(points: latestMatch?.heatmapPoints ?? [])
                    .padding(16)
            }

            Text(latestMatch?.title ?? "Test Match")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.secondaryText)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [MatchHistoryItem.self, GPSPoint.self], inMemory: true)
}
