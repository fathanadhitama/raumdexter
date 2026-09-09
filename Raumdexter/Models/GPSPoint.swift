//
//  GPSPoint.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//
import Foundation
import SwiftData

// swiftlint:disable identifier_name

/// Satu titik posisi pemain di lapangan, hasil kalibrasi data GPS dari Apple Watch
/// ke koordinat lapangan yang dinormalisasi (0...1 pada sumbu x & y).
@Model
final class GPSPoint {
    var x: Double
    var y: Double
    var timestamp: Date

    init(x: Double, y: Double, timestamp: Date) {
        self.x = x
        self.y = y
        self.timestamp = timestamp
    }
}

extension GPSPoint {
    /// Dummy data yang mensimulasikan jejak GPS pemain selama satu pertandingan,
    /// sebagai pengganti sementara sebelum data asli dari watch tersedia.
    static func mockMatchPoints(count: Int = 900) -> [GPSPoint] {
        struct Cluster {
            let cx: Double
            let cy: Double
            let spread: Double
            let weight: Double
        }

        // Simulasi pemain gelandang: banyak di tengah, sesekali membantu serangan sayap kanan.
        let clusters: [Cluster] = [
            Cluster(cx: 0.50, cy: 0.50, spread: 0.13, weight: 0.32),
            Cluster(cx: 0.35, cy: 0.55, spread: 0.14, weight: 0.22),
            Cluster(cx: 0.62, cy: 0.30, spread: 0.10, weight: 0.18),
            Cluster(cx: 0.72, cy: 0.50, spread: 0.09, weight: 0.16),
            Cluster(cx: 0.45, cy: 0.75, spread: 0.10, weight: 0.12)
        ]

        let totalWeight = clusters.reduce(0) { $0 + $1.weight }
        let start = Date().addingTimeInterval(-90 * 60) // 90 menit lalu
        let interval = (90.0 * 60.0) / Double(count)

        var points: [GPSPoint] = []
        points.reserveCapacity(count)

        for i in 0..<count {
            let r = Double.random(in: 0...totalWeight)
            var cumulative = 0.0
            let cluster = clusters.first { c in
                cumulative += c.weight
                return r <= cumulative
            } ?? clusters[0]

            let x = gaussianSample(mean: cluster.cx, stdDev: cluster.spread)
            let y = gaussianSample(mean: cluster.cy, stdDev: cluster.spread)

            points.append(
                GPSPoint(
                    x: min(max(x, 0.02), 0.98),
                    y: min(max(y, 0.02), 0.98),
                    timestamp: start.addingTimeInterval(Double(i) * interval)
                )
            )
        }

        return points
    }

    private static func gaussianSample(mean: Double, stdDev: Double) -> Double {
        let u1 = Double.random(in: 0.0001...1)
        let u2 = Double.random(in: 0...1)
        let z0 = sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
        return mean + z0 * stdDev
    }
    
    /// Ubah rekaman GPS mentah dari watch (relatif ke titik tengah lapangan) jadi koordinat
    /// lapangan ternormalisasi (0...1). `ownGoal` dipakai buat nentuin orientasi lapangan yang
    /// sebenarnya (gak diasumsikan ngarah utara).
    ///
    /// Lapangan digambar landscape (gawang di kiri & kanan), jadi:
    /// - sumbu `x` = panjang lapangan, gawang sendiri di kiri (x → 0), arah serang ke kanan
    /// - sumbu `y` = lebar lapangan
    static func calibrated(
        samples: [LocationSample],
        center: LocationSample,
        ownGoal: LocationSample,
        field: FieldDimensions = .miniSoccer
    ) -> [GPSPoint] {
        let centerLatRad = center.latitude * .pi / 180
        let metersPerDegreeLat = 111_132.92 - 559.82 * cos(2 * centerLatRad)
        let metersPerDegreeLon = 111_412.84 * cos(centerLatRad)

        // Arah kompas dari titik tengah ke gawang sendiri — ini yang jadi sumbu "panjang" lapangan.
        let bearing = bearingRadians(from: center, to: ownGoal)

        return samples.map { sample in
            let deltaEast = (sample.longitude - center.longitude) * metersPerDegreeLon
            let deltaNorth = (sample.latitude - center.latitude) * metersPerDegreeLat

            // Proyeksikan ke sumbu lapangan: "toOwnGoal" searah gawang sendiri,
            // "acrossField" tegak lurus terhadapnya (lebar lapangan).
            let toOwnGoal = deltaEast * sin(bearing) + deltaNorth * cos(bearing)
            let acrossField = deltaEast * cos(bearing) - deltaNorth * sin(bearing)

            let posX = 0.5 - toOwnGoal / field.lengthMeters
            let posY = 0.5 + acrossField / field.widthMeters

            return GPSPoint(
                x: min(max(posX, 0), 1),
                y: min(max(posY, 0), 1),
                timestamp: sample.timestamp
            )
        }
    }

    /// Arah kompas (radian, 0 = utara, positif searah jarum jam) dari satu titik GPS ke titik lain.
    private static func bearingRadians(from start: LocationSample, to end: LocationSample) -> Double {
        let lat1 = start.latitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let deltaLon = (end.longitude - start.longitude) * .pi / 180

        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        return atan2(y, x)
    }
}

// swiftlint:enable identifier_name
