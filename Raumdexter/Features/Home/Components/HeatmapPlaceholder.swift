//
//  HeatmapPlaceholder.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//
import SwiftUI

struct HeatmapPlaceholderView: View {
    let points: [GPSPoint]

    init(points: [GPSPoint] = GPSPoint.mockMatchPoints(count: 200)) {
        self.points = points
    }

    private let gridColumns = 26
    private let gridRows = 24

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.green.opacity(0.08))

            GeometryReader { geo in
                ZStack {
                    heatmapLayer(size: geo.size)
                    fieldLines(size: geo.size)
//                    Text("\(Int(geo.size.width))x\(Int(geo.size.height))" )
//                        .foregroundColor(.white)
                }
            }
//            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            if points.isEmpty {
                Text("Heatmap belum tersedia")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .frame(height: 220)
//        .background(.red)
    }

    // MARK: - Heat layer

    private struct GridKey: Hashable { let col: Int; let row: Int }

    private func densityGrid() -> [GridKey: Double] {
        var grid: [GridKey: Double] = [:]
        for point in points {
            let col = min(max(Int(point.x * Double(gridColumns)), 0), gridColumns - 1)
            let row = min(max(Int(point.y * Double(gridRows)), 0), gridRows - 1)
            grid[GridKey(col: col, row: row), default: 0] += 1
        }
        return grid
    }

    private func heatmapLayer(size: CGSize) -> some View {
        let grid = densityGrid()
        let maxDensity = grid.values.max() ?? 1
        let cellW = size.width / CGFloat(gridColumns)
        let cellH = size.height / CGFloat(gridRows)
        let radius = max(cellW, cellH) * 1.6

        // Diurutkan dari intensitas terendah ke tertinggi supaya area terpanas (merah)
        // digambar paling akhir dan tidak tertimbun warna dingin di sekitarnya.
        let orderedCells = grid.sorted { $0.value < $1.value }

        return Canvas { context, _ in
            context.addFilter(.blur(radius: radius * 0.5))
            context.drawLayer { ctx in
                for (key, count) in orderedCells {
                    let intensity = min(count / maxDensity, 1.0)
                    guard intensity > 0.02 else { continue }

                    let centerX = (CGFloat(key.col) + 0.5) * cellW
                    let centerY = (CGFloat(key.row) + 0.5) * cellH
                    let rect = CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2)

                    ctx.opacity = min(0.25 + intensity * 0.65, 0.9)
                    ctx.fill(Path(ellipseIn: rect), with: .color(heatColor(for: intensity)))
                }
            }
        }
    }

    /// Palet klasik heatmap: biru (jarang dilewati) -> hijau -> kuning -> merah (paling sering dilewati).
    private func heatColor(for intensity: Double) -> Color {
        // swiftlint:disable:next large_tuple
        let stops: [(t: Double, r: Double, g: Double, b: Double)] = [
            (0.0, 0.20, 0.40, 0.95),
            (0.35, 0.20, 0.85, 0.45),
            (0.6, 0.95, 0.85, 0.20),
            (0.8, 0.95, 0.55, 0.15),
            (1.0, 0.90, 0.15, 0.15)
        ]

        let clamped = min(max(intensity, 0), 1)
        for stop in 1..<stops.count {
            let prev = stops[stop - 1]
            let curr = stops[stop]
            if clamped <= curr.t {
                let span = curr.t - prev.t
                let localT = span > 0 ? (clamped - prev.t) / span : 0
                return Color(
                    red: prev.r + (curr.r - prev.r) * localT,
                    green: prev.g + (curr.g - prev.g) * localT,
                    blue: prev.b + (curr.b - prev.b) * localT
                )
            }
        }
        let last = stops[stops.count - 1]
        return Color(red: last.r, green: last.g, blue: last.b)
    }

    // MARK: - Field lines

    private func fieldLines(size: CGSize) -> some View {
        Path { path in
            let width = size.width
            let height = size.height
            let inset: CGFloat = 0
            let rect = CGRect(x: inset, y: inset, width: width - inset * 2, height: height - inset * 2)

            path.addRect(rect)

            // Garis tengah
            path.move(to: CGPoint(x: width / 2, y: rect.minY))
            path.addLine(to: CGPoint(x: width / 2, y: rect.maxY))

            // Lingkaran tengah
            let circleRadius = min(width, height) * 0.12
            path.addEllipse(in: CGRect(x: width / 2 - circleRadius, y: height / 2 - circleRadius, width: circleRadius * 2, height: circleRadius * 2))

            // Kotak penalti kiri & kanan
            let boxWidth = rect.width * 0.16
            let boxHeight = rect.height * 0.5
            path.addRect(CGRect(x: rect.minX, y: height / 2 - boxHeight / 2, width: boxWidth, height: boxHeight))
            path.addRect(CGRect(x: rect.maxX - boxWidth, y: height / 2 - boxHeight / 2, width: boxWidth, height: boxHeight))

            // Kotak gawang (6-yard box) kiri & kanan
            let goalWidth = rect.width * 0.06
            let goalHeight = rect.height * 0.24
            path.addRect(CGRect(x: rect.minX, y: height / 2 - goalHeight / 2, width: goalWidth, height: goalHeight))
            path.addRect(CGRect(x: rect.maxX - goalWidth, y: height / 2 - goalHeight / 2, width: goalWidth, height: goalHeight))
        }
        .stroke(AppTheme.accentGreen.opacity(0.45), lineWidth: 1.5)
    }
}

#Preview {
    HeatmapPlaceholderView()
        .frame(height: 290)
        .padding()
        .background(AppTheme.background)
}
