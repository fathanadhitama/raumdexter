//
//  MatchDetailViewModel.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

@MainActor
final class MatchDetailViewModel: ObservableObject {
    @Published var isSharePresented = false
    @Published var isActivityPresented = false
    @Published var shareImage: UIImage?
    @Published var isDeleteConfirmationPresented = false

    func share(_ match: MatchHistoryItem) {
        shareImage = renderImage(ShareableMatchCard(match: match))
        isSharePresented = shareImage != nil
    }

    func saveShareImage() async -> Bool {
        guard let shareImage else { return false }
        return await saveImageToPhotos(shareImage)
    }

    func delete(_ match: MatchHistoryItem, context: ModelContext) {
        context.delete(match)
        try? context.save()
    }
}
