//
//  AppTheme.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import SwiftUI

/// Design tokens aplikasi. Tema gelap minimalis: background nyaris hitam dengan
/// semburat biru, satu warna aksen biru elektrik, dan permukaan kartu bertingkat.
enum AppTheme {

    // MARK: - Surfaces

    static let background = Color(hex: "0A0C14")
    static let surface = Color(hex: "161A28")
    static let surfaceElevated = Color(hex: "1E2333")
    static let stroke = Color.white.opacity(0.07)
    static let divider = Color.white.opacity(0.06)

    // MARK: - Text

    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.55)
    static let tertiaryText = Color.white.opacity(0.32)

    // MARK: - Accent

    static let accent = Color(hex: "3E7BFF")
    static let accentSoft = Color(hex: "3E7BFF").opacity(0.14)
    static let pitchGreen = Color(hex: "37D67A")
    static let danger = Color(hex: "FF4D5E")

    // Alias lama supaya file yang belum diupdate tetap kompilasi.
    static let cardBackground = surface
    static let accentBlue = accent
    static let accentGreen = pitchGreen

    // MARK: - Gradients

    static let accentGradient = LinearGradient(
        colors: [Color(hex: "4C8DFF"), Color(hex: "2547D0")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "141A2E"), Color(hex: "0A0C14")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroGradient = LinearGradient(
        colors: [Color(hex: "1E2E63"), Color(hex: "111633"), Color(hex: "0A0C14")],
        startPoint: .topTrailing,
        endPoint: .bottom
    )

    static let pitchGradient = LinearGradient(
        colors: [Color(hex: "13291F"), Color(hex: "0B1A14")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Reusable styling

extension View {
    /// Permukaan kartu standar: warna surface + stroke tipis + sudut membulat.
    func cardSurface(cornerRadius: CGFloat = 20, color: Color = AppTheme.surface) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(color)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            )
    }
}

/// Label kecil huruf besar berspasi, dipakai untuk judul seksi & label statistik.
struct SectionLabel: View {
    let text: String
    var color: Color = AppTheme.tertiaryText
    var size: CGFloat = 11

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: size, weight: .semibold, design: .rounded))
            .tracking(1.2)
            .foregroundColor(color)
    }
}
