//
//  HeatmapRenderer.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 09/09/26.
//

import CoreGraphics
import Foundation

/// Satu titik posisi ternormalisasi (0...1) yang siap dihitung di luar main actor.
struct HeatPoint: Sendable {
    let posX: Double
    let posY: Double
}

/// Bikin gambar heatmap gaya *kernel density estimation* (KDE).
///
/// Alurnya: titik-titik di-splat ke grid density, di-blur pakai Gaussian (ini yang
/// bikin permukaannya kontinu & mulus seperti KDE plot), dinormalisasi, lalu
/// tiap sel dipetakan ke warna lewat colormap hijau → kuning → oranye → merah.
enum HeatmapRenderer {

    /// Resolusi grid density — bukan resolusi layar. Hasilnya di-upscale dengan
    /// interpolasi waktu digambar, jadi grid kecil pun tetap kelihatan halus.
    private static let gridWidth = 160

    /// Lebar kernel Gaussian relatif terhadap lebar grid. Makin besar = makin "melebar" blob-nya.
    private static let sigmaRatio = 0.038

    /// Persentil yang dipakai sebagai nilai "paling panas", biar satu sel ekstrem
    /// nggak bikin sisanya jadi pudar semua.
    private static let normalizationPercentile = 0.97

    nonisolated static func render(points: [HeatPoint], aspectRatio: Double) -> CGImage? {
        guard !points.isEmpty, aspectRatio > 0 else { return nil }

        let width = gridWidth
        let height = max(1, Int((Double(gridWidth) / aspectRatio).rounded()))

        let density = gaussianBlur(
            splat(points, width: width, height: height),
            width: width,
            height: height,
            sigma: Double(width) * sigmaRatio
        )

        guard let peak = percentile(of: density, ratio: normalizationPercentile), peak > 0 else { return nil }

        return makeImage(density: density, peak: peak, width: width, height: height)
    }

    // MARK: - 1. Splat titik ke grid

    private nonisolated static func splat(_ points: [HeatPoint], width: Int, height: Int) -> [Double] {
        var field = [Double](repeating: 0, count: width * height)

        for point in points {
            // Bilinear splat: satu titik dibagi ke 4 sel tetangga sesuai posisi pecahannya,
            // supaya distribusinya halus dan nggak "kotak-kotak".
            let floatX = min(max(point.posX, 0), 1) * Double(width - 1)
            let floatY = min(max(point.posY, 0), 1) * Double(height - 1)

            let leftX = Int(floatX)
            let topY = Int(floatY)
            let rightX = min(leftX + 1, width - 1)
            let bottomY = min(topY + 1, height - 1)

            let fracX = floatX - Double(leftX)
            let fracY = floatY - Double(topY)

            field[topY * width + leftX] += (1 - fracX) * (1 - fracY)
            field[topY * width + rightX] += fracX * (1 - fracY)
            field[bottomY * width + leftX] += (1 - fracX) * fracY
            field[bottomY * width + rightX] += fracX * fracY
        }

        return field
    }

    // MARK: - 2. Gaussian blur (separable)

    private nonisolated static func gaussianBlur(_ source: [Double], width: Int, height: Int, sigma: Double) -> [Double] {
        let radius = max(1, Int((sigma * 3).rounded()))
        let kernel = gaussianKernel(radius: radius, sigma: sigma)

        var horizontal = [Double](repeating: 0, count: source.count)
        for row in 0..<height {
            let rowOffset = row * width
            for column in 0..<width {
                var total = 0.0
                for offset in -radius...radius {
                    let sampleX = min(max(column + offset, 0), width - 1)
                    total += source[rowOffset + sampleX] * kernel[offset + radius]
                }
                horizontal[rowOffset + column] = total
            }
        }

        var result = [Double](repeating: 0, count: source.count)
        for row in 0..<height {
            for column in 0..<width {
                var total = 0.0
                for offset in -radius...radius {
                    let sampleY = min(max(row + offset, 0), height - 1)
                    total += horizontal[sampleY * width + column] * kernel[offset + radius]
                }
                result[row * width + column] = total
            }
        }

        return result
    }

    private nonisolated static func gaussianKernel(radius: Int, sigma: Double) -> [Double] {
        var kernel = [Double](repeating: 0, count: radius * 2 + 1)
        var total = 0.0

        for offset in -radius...radius {
            let value = exp(-Double(offset * offset) / (2 * sigma * sigma))
            kernel[offset + radius] = value
            total += value
        }

        guard total > 0 else { return kernel }
        return kernel.map { $0 / total }
    }

    // MARK: - 3. Normalisasi

    private nonisolated static func percentile(of values: [Double], ratio: Double) -> Double? {
        let positives = values.filter { $0 > 0 }.sorted()
        guard !positives.isEmpty else { return nil }

        let index = min(positives.count - 1, Int(Double(positives.count - 1) * ratio))
        return positives[index]
    }

    // MARK: - 4. Colormap + bitmap

    private nonisolated static func makeImage(density: [Double], peak: Double, width: Int, height: Int) -> CGImage? {
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for index in 0..<(width * height) {
            // Kurva kontras sedikit dinaikin biar gradasi tengahnya lebih kebaca,
            // mirip heatmap analitik sepak bola pada umumnya.
            let normalized = min(density[index] / peak, 1)
            let intensity = pow(normalized, 0.75)
            let color = heatColor(for: intensity)

            let offset = index * 4
            // Premultiplied alpha
            pixels[offset] = UInt8((color.red * color.alpha * 255).rounded())
            pixels[offset + 1] = UInt8((color.green * color.alpha * 255).rounded())
            pixels[offset + 2] = UInt8((color.blue * color.alpha * 255).rounded())
            pixels[offset + 3] = UInt8((color.alpha * 255).rounded())
        }

        return pixels.withUnsafeMutableBytes { buffer -> CGImage? in
            guard let base = buffer.baseAddress,
                  let context = CGContext(
                    data: base,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                  )
            else { return nil }

            return context.makeImage()
        }
    }

    // swiftlint:disable:next large_tuple
    private nonisolated static func heatColor(for intensity: Double) -> (red: Double, green: Double, blue: Double, alpha: Double) {
        // Colormap ala heatmap sepak bola: transparan → hijau → kuning → oranye → merah.
        // swiftlint:disable:next large_tuple
        let stops: [(t: Double, red: Double, green: Double, blue: Double, alpha: Double)] = [
            (0.00, 0.10, 0.62, 0.28, 0.00),
            (0.16, 0.12, 0.68, 0.30, 0.12),
            (0.34, 0.16, 0.76, 0.28, 0.52),
            (0.52, 0.55, 0.85, 0.20, 0.72),
            (0.68, 0.94, 0.87, 0.16, 0.82),
            (0.82, 0.98, 0.55, 0.10, 0.88),
            (1.00, 0.90, 0.13, 0.10, 0.94)
        ]

        let clamped = min(max(intensity, 0), 1)

        for index in 1..<stops.count {
            let previous = stops[index - 1]
            let current = stops[index]
            guard clamped <= current.t else { continue }

            let span = current.t - previous.t
            let ratio = span > 0 ? (clamped - previous.t) / span : 0

            return (
                red: previous.red + (current.red - previous.red) * ratio,
                green: previous.green + (current.green - previous.green) * ratio,
                blue: previous.blue + (current.blue - previous.blue) * ratio,
                alpha: previous.alpha + (current.alpha - previous.alpha) * ratio
            )
        }

        let last = stops[stops.count - 1]
        return (last.red, last.green, last.blue, last.alpha)
    }
}
