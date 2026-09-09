//
//  HomeViewModel.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import Foundation
import Combine

// @MainActor
final class HomeViewModel: ObservableObject {
 
    @Published var player: PlayerProfile
    @Published var isSharePresented: Bool = false
    @Published var shareImage: UIImage?


    init(
        player: PlayerProfile = HomeViewModel.mockPlayer
    ) {
        self.player = player
    }
 
    // MARK: - Actions
 
//    func shareLatestMatch() {
//        isSharePresented = true
//    }
    
    func shareLatestMatch(_ match: MatchHistoryItem?) {
        guard let match else { return }
        shareImage = renderImage(ShareableMatchCard(match: match))
        isSharePresented = shareImage != nil
    }

    @MainActor
    func saveShareImage() async -> Bool {
        guard let shareImage else { return false }
        return await saveImageToPhotos(shareImage)
    }
 
    // MARK: - Formatted values (untuk UI)
 
    var matchCountText: String { "\(player.totalMatches)" }
    var goalCountText: String { "\(player.totalGoals)" }
    var assistCountText: String { "\(player.totalAssists)" }
    var avgDistanceText: String { String(format: "%.1f km", player.avgDistanceKm) }
 
    // MARK: - Mock data (ganti dengan data asli / API nanti)
 
    static let mockPlayer = PlayerProfile(
        name: "Fathan",
        jerseyNumber: 22,
        photoName: "fathan-pic",
        totalMatches: 100,
        totalGoals: 7,
        totalAssists: 18,
        avgDistanceKm: 6.3
    )
 
    static let mockMatch = MatchSummary(
        title: "Sunday League Match 123",
        heatmapPoints: [],
        date: Date()
    )
}
