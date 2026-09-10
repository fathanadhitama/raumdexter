//
//  HomeViewModel.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import Foundation
import Combine

final class HomeViewModel: ObservableObject {

    @Published var isSharePresented: Bool = false
    @Published var isEditProfilePresented: Bool = false
    @Published var shareImage: UIImage?

    // MARK: - Actions

    func editProfile() {
        isEditProfilePresented = true
    }

    func shareLatestMatch(_ match: MatchHistoryItem?) {
        guard let match else { return }
        let heatPoints = match.heatmapPoints.map { HeatPoint(posX: $0.x, posY: $0.y) }
        let heat = HeatmapRenderer.render(
            points: heatPoints,
            aspectRatio: FieldDimensions.miniSoccer.aspectRatio
        )

        shareImage = renderImage(ShareableMatchCard(match: match, heatImage: heat))
        isSharePresented = shareImage != nil
    }

    @MainActor
    func saveShareImage() async -> Bool {
        guard let shareImage else { return false }
        return await saveImageToPhotos(shareImage)
    }
}
