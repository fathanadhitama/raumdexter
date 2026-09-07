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
                data: image.jpegData(compressionQuality: 0.95) ?? Data(),
                options: nil
            )
        }
        return true
    } catch {
        return false
    }
}
