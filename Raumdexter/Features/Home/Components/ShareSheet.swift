//
//  ShareSheet.swift
//  Raumdexter
//

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
    let onSave: () -> Void
    let onInstagram: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
//                Color.black.opacity(0.82)

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

            VStack(spacing: 24) {
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)

                Text("SHARE MATCH")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.42))

                HStack(spacing: 26) {
                    ShareActionButton(title: "Instagram", systemImage: "camera.fill", color: .pink, action: onInstagram)
                    ShareActionButton(title: "Save image", systemImage: "arrow.down.to.line", color: Color.black.opacity(0.55), action: onSave)
                }
            }
            .padding(.bottom, 30)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .ignoresSafeArea()
        .presentationBackground(.clear)
    }
}

private struct ShareActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 66, height: 66)
                    .background(Color.black.opacity(0.035), in: Circle())

                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.58))
                    .lineLimit(1)
            }
        }
    }
}
