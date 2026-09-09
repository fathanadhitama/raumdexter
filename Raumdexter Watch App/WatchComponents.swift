//
//  WatchComponents.swift
//  Raumdexter Watch App
//
//  Created by Fathan Naufal Adhitama on 08/09/26.
//

import SwiftUI

/// Tombol aksi utama. Saat `isLoading` aktif, tombol otomatis nonaktif dan
/// nampilin spinner + teks proses supaya user tau prosesnya lagi jalan (bukan nge-hang).
struct PrimaryWatchButton: View {
    let title: String
    var loadingTitle: String = "Loading…"
    var systemImage: String?
    var tint: Color = WatchTheme.accent
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    private var inactive: Bool { isLoading || isDisabled }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.55)
                        .tint(.white)
                        .frame(width: 14, height: 14)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .semibold))
                }

                Text(isLoading ? loadingTitle : title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(Capsule().fill(inactive ? tint.opacity(0.35) : tint))
            .foregroundStyle(inactive ? Color.white.opacity(0.7) : .white)
        }
        .buttonStyle(.plain)
        .disabled(inactive)
    }
}

/// Badge langkah kecil di atas layar kalibrasi ("STEP 1 OF 2").
struct StepBadge: View {
    let step: Int
    let total: Int

    var body: some View {
        Text("STEP \(step) OF \(total)")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(1.1)
            .foregroundStyle(WatchTheme.accent)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Capsule().fill(WatchTheme.accent.opacity(0.16)))
    }
}

/// Baris counter goal/assist dengan tombol tambah–kurang.
struct CounterRow: View {
    let label: String
    let count: Int
    let tint: Color
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            stepperButton(systemImage: "minus", action: onDecrement)
                .disabled(count == 0)
                .opacity(count == 0 ? 0.35 : 1)

            Spacer(minLength: 0)

            VStack(spacing: 0) {
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(WatchTheme.primaryText)
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(WatchTheme.secondaryText)
            }

            Spacer(minLength: 0)

            stepperButton(systemImage: "plus", action: onIncrement)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(WatchTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tint.opacity(0.25), lineWidth: 1)
        )
    }

    private func stepperButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(Circle().fill(tint.opacity(0.18)))
        }
        .buttonStyle(.plain)
    }
}

/// Pesan error ringkas (misal GPS gagal dapat sinyal).
struct InlineErrorText: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10, weight: .semibold))
            Text(message)
                .font(.system(size: 11, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(WatchTheme.danger)
        .multilineTextAlignment(.leading)
    }
}
