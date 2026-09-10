//
//  ShareSheet.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI
import UIKit

struct SharePreviewView: View {
    let image: UIImage
    /// Balikin `true` kalau gambar berhasil masuk galeri — dipakai buat nentuin feedback.
    let onSave: () async -> Bool
    let onInstagram: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var saveState: SaveState = .idle

    private enum SaveState: Equatable {
        case idle
        case saving
        case saved
        case failed
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 24)

                Button(
                    action: { dismiss() },
                    label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 44, height: 44)
                    }
                )
                .padding(.top, 8)
                .padding(.leading, 12)
            }
            .frame(maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                if saveState == .saved {
                    savedToast
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)

                Text("SHARE MATCH")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.42))

                HStack(spacing: 26) {
                    ShareActionButton(
                        title: "Instagram",
                        icon: Image("instagram-logo"),
                        color: .pink,
                        action: onInstagram
                    )

                    ShareActionButton(
                        title: saveButtonTitle,
                        icon: Image(systemName: saveButtonIcon),
                        color: saveButtonColor,
                        isLoading: saveState == .saving,
                        action: { Task { await handleSave() } }
                    )
                    .disabled(saveState == .saving)
                }
            }
            .padding(.bottom, 30)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .ignoresSafeArea()
        .presentationBackground(.clear)
        .animation(.easeInOut(duration: 0.25), value: saveState)
        .alert("Failed to save", isPresented: .constant(saveState == .failed)) {
            Button("OK") { saveState = .idle }
        } message: {
            Text("Raumdexter doesn't have permission to save photos to your photo library. Please, allow it from Settings › Privacy & Security › Photos.")
        }
    }

    // MARK: - Save

    private var saveButtonTitle: String {
        switch saveState {
        case .saved: "Saved"
        case .saving: "Saving…"
        default: "Save image"
        }
    }

    private var saveButtonIcon: String {
        saveState == .saved ? "checkmark" : "arrow.down.to.line"
    }

    private var saveButtonColor: Color {
        saveState == .saved ? Color(red: 0.13, green: 0.65, blue: 0.33) : Color.black.opacity(0.55)
    }

    private func handleSave() async {
        guard saveState != .saving else { return }
        saveState = .saving

        let success = await onSave()
        saveState = success ? .saved : .failed

        guard success else { return }

        // Balikin tombol ke keadaan normal setelah user sempat lihat konfirmasinya.
        try? await Task.sleep(for: .seconds(2.5))
        if saveState == .saved {
            saveState = .idle
        }
    }

    private var savedToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(red: 0.29, green: 0.85, blue: 0.48))

            Text("Image saved to gallery")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule().fill(Color.black.opacity(0.78))
        )
        .overlay(
            Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct ShareActionButton: View {
    let title: String
    let icon: Image
    let color: Color
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Group {
                    if isLoading {
                        ProgressView()
                            .tint(color)
                    } else {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 23, height: 23)
                            .foregroundStyle(color)
                    }
                }
                .frame(width: 66, height: 66)
                .background(
                    Color.black.opacity(0.035),
                    in: Circle()
                )

                Text(title)
                    .font(.system(
                        size: 14,
                        weight: .medium,
                        design: .rounded
                    ))
                    .foregroundColor(Color.black.opacity(0.58))
                    .lineLimit(1)
            }
        }
    }
}
