//
//  Helpers.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 04/09/26.
//

import SwiftUI
import Photos

let instagramAppID = "1243890727644320"

@MainActor
func renderImage<Content: View>(_ view: Content, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
    let renderer = ImageRenderer(content: view)
    renderer.scale = scale
    return renderer.uiImage
}

@MainActor
func saveImageToPhotos(_ image: UIImage) async -> Bool {
    let authorization = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
    guard authorization == .authorized || authorization == .limited else { return false }

    do {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.forAsset().addResource(
                with: .photo,
                data: image.pngData() ?? Data(),
                options: nil
            )
        }
        return true
    } catch {
        return false
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
