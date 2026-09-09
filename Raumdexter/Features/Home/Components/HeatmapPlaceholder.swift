//
//  HeatmapPlaceholder.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//
import SwiftUI

/// Visualisasi heatmap posisi pemain (gaya KDE plot) di atas gambar lapangan.
///
/// View ini nentuin tingginya sendiri lewat `aspectRatio` sesuai proporsi lapangan,
/// jadi pemanggil cukup ngasih lebar (otomatis dari layout) tanpa perlu hardcode `.frame(height:)`.
struct HeatmapPlaceholderView: View {
    let points: [GPSPoint]
    let field: FieldDimensions
    let injectedImage: CGImage?

    @State private var heatImage: CGImage?

    init(points: [GPSPoint] = GPSPoint.mockMatchPoints(count: 200), field: FieldDimensions = .miniSoccer,
         injectedImage: CGImage? = nil) {
        self.points = points
        self.field = field
        self.injectedImage = injectedImage
    }

    private let cornerRadius: CGFloat = 16

    /// Kunci stabil per dataset — render ulang cuma kalau datanya beneran ganti,
    /// bukan tiap kali view redraw (penting buat list History yang di-scroll).
    private var renderKey: String {
        let first = points.first?.timestamp.timeIntervalSince1970 ?? 0
        let last = points.last?.timestamp.timeIntervalSince1970 ?? 0
        return "\(points.count)-\(first)-\(last)"
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                pitchBackground

                if let image = injectedImage ?? heatImage {
                    Image(decorative: image, scale: 1)
                        .resizable()
                        .interpolation(.high)
                }

                fieldLines(size: geo.size)

                if points.isEmpty {
                    emptyState
                }
            }
        }
        .aspectRatio(field.aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .task(id: renderKey) {
            await renderHeatmap()
        }
    }

    private func renderHeatmap() async {
        guard injectedImage == nil else { return }

        guard !points.isEmpty else {
            heatImage = nil
            return
        }

        // Baca properti model di main actor dulu, komputasi beratnya baru dilempar ke background.
        let heatPoints = points.map { HeatPoint(posX: $0.x, posY: $0.y) }
        let aspectRatio = field.aspectRatio

        heatImage = await Task.detached(priority: .userInitiated) {
            HeatmapRenderer.render(points: heatPoints, aspectRatio: aspectRatio)
        }.value
    }

    // MARK: - Pitch background

    private var pitchBackground: some View {
        ZStack {
            Rectangle().fill(AppTheme.pitchGradient)

            // Garis potong rumput halus biar terasa seperti lapangan asli.
            GeometryReader { geo in
                let stripeWidth = geo.size.width / 8
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { index in
                        Rectangle()
                            .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.012 : 0))
                            .frame(width: stripeWidth)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppTheme.tertiaryText)
            Text("Belum ada data")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.tertiaryText)
        }
    }

    // MARK: - Field lines

    private func fieldLines(size: CGSize) -> some View {
        Path { path in
            let inset: CGFloat = 10
            let rect = CGRect(
                x: inset,
                y: inset,
                width: size.width - inset * 2,
                height: size.height - inset * 2
            )

            path.addRect(rect)

            // Garis tengah
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

            // Lingkaran tengah
            let circleRadius = rect.height * 0.16
            path.addEllipse(
                in: CGRect(
                    x: rect.midX - circleRadius,
                    y: rect.midY - circleRadius,
                    width: circleRadius * 2,
                    height: circleRadius * 2
                )
            )

            // Kotak penalti kiri & kanan
            let boxWidth = rect.width * 0.15
            let boxHeight = rect.height * 0.55
            path.addRect(CGRect(x: rect.minX, y: rect.midY - boxHeight / 2, width: boxWidth, height: boxHeight))
            path.addRect(CGRect(x: rect.maxX - boxWidth, y: rect.midY - boxHeight / 2, width: boxWidth, height: boxHeight))

            // Kotak gawang kiri & kanan
            let goalWidth = rect.width * 0.055
            let goalHeight = rect.height * 0.26
            path.addRect(CGRect(x: rect.minX, y: rect.midY - goalHeight / 2, width: goalWidth, height: goalHeight))
            path.addRect(CGRect(x: rect.maxX - goalWidth, y: rect.midY - goalHeight / 2, width: goalWidth, height: goalHeight))
        }
        .stroke(Color.white.opacity(0.38), lineWidth: 1)
    }
}

#Preview {
    VStack(spacing: 20) {
        HeatmapPlaceholderView(points: GPSPoint.mockMatchPoints(count: 400))
        HeatmapPlaceholderView(points: [])
    }
    .padding(20)
    .background(AppTheme.background)
}
