//
//  DummyMatchData.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 10/09/26.
//
//  TEMPORARY: sumber data match dummy buat nampilin variasi heatmap
//  (right wing, centre back, midfielder, dst) tanpa nunggu data asli dari watch.
//  Dipakai sementara di HomeView / HistoryView / StatsCard menggantikan @Query.
//  Kalau udah gak perlu, tinggal hapus file ini dan balikin @Query di tiga tempat itu.
//

import Foundation

enum DummyMatchData {

    // MARK: - Generator titik (pola sama kayak GPSPoint.mockMatchPoints, tapi cluster-nya bisa diatur)

    struct Cluster {
        let cx: Double
        let cy: Double
        let spread: Double
        let weight: Double
    }

    static func points(clusters: [Cluster], count: Int, matchDate: Date) -> [GPSPoint] {
        let totalWeight = clusters.reduce(0) { $0 + $1.weight }
        let start = matchDate.addingTimeInterval(-90 * 60)
        let interval = (90.0 * 60.0) / Double(count)

        var points: [GPSPoint] = []
        points.reserveCapacity(count)

        for index in 0..<count {
            let roll = Double.random(in: 0...totalWeight)
            var cumulative = 0.0
            let cluster = clusters.first { candidate in
                cumulative += candidate.weight
                return roll <= cumulative
            } ?? clusters[0]

            let posX = gaussianSample(mean: cluster.cx, stdDev: cluster.spread)
            let posY = gaussianSample(mean: cluster.cy, stdDev: cluster.spread)

            points.append(
                GPSPoint(
                    x: min(max(posX, 0.02), 0.98),
                    y: min(max(posY, 0.02), 0.98),
                    timestamp: start.addingTimeInterval(Double(index) * interval)
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

    // MARK: - Pola posisi
    // Ingat konvensi GPSPoint: x=0 gawang sendiri, x=1 gawang lawan (arah serang), y = lebar lapangan (0...1)

    static var rightWinger: [Cluster] {
        [
            Cluster(cx: 0.74, cy: 0.86, spread: 0.09, weight: 0.40), // sepertiga akhir sisi kanan
            Cluster(cx: 0.55, cy: 0.80, spread: 0.09, weight: 0.22), // bantu build-up di sisi kanan
            Cluster(cx: 0.86, cy: 0.62, spread: 0.08, weight: 0.20), // cut inside dekat kotak penalti
            Cluster(cx: 0.40, cy: 0.72, spread: 0.10, weight: 0.10), // sesekali turun bantu bertahan
            Cluster(cx: 0.58, cy: 0.50, spread: 0.08, weight: 0.08)
        ]
    }

    static var centreBack: [Cluster] {
        [
            Cluster(cx: 0.18, cy: 0.50, spread: 0.07, weight: 0.42), // jantung pertahanan
            Cluster(cx: 0.15, cy: 0.34, spread: 0.06, weight: 0.16),
            Cluster(cx: 0.15, cy: 0.66, spread: 0.06, weight: 0.16),
            Cluster(cx: 0.30, cy: 0.50, spread: 0.08, weight: 0.16), // dorong maju dikit
            Cluster(cx: 0.42, cy: 0.50, spread: 0.07, weight: 0.10) // sesekali ikut set piece
        ]
    }

    static var centralMidfielder: [Cluster] {
        [
            Cluster(cx: 0.50, cy: 0.50, spread: 0.14, weight: 0.34),
            Cluster(cx: 0.34, cy: 0.44, spread: 0.12, weight: 0.22),
            Cluster(cx: 0.66, cy: 0.56, spread: 0.12, weight: 0.20),
            Cluster(cx: 0.24, cy: 0.56, spread: 0.10, weight: 0.12),
            Cluster(cx: 0.76, cy: 0.44, spread: 0.10, weight: 0.12)
        ]
    }

    static var striker: [Cluster] {
        [
            Cluster(cx: 0.86, cy: 0.50, spread: 0.07, weight: 0.38),
            Cluster(cx: 0.78, cy: 0.34, spread: 0.08, weight: 0.20),
            Cluster(cx: 0.78, cy: 0.66, spread: 0.08, weight: 0.20),
            Cluster(cx: 0.64, cy: 0.50, spread: 0.10, weight: 0.13),
            Cluster(cx: 0.54, cy: 0.50, spread: 0.09, weight: 0.09)
        ]
    }

    static var leftBack: [Cluster] {
        [
            Cluster(cx: 0.32, cy: 0.12, spread: 0.10, weight: 0.30), // naik-turun sisi kiri
            Cluster(cx: 0.56, cy: 0.15, spread: 0.11, weight: 0.28),
            Cluster(cx: 0.20, cy: 0.20, spread: 0.08, weight: 0.20),
            Cluster(cx: 0.70, cy: 0.16, spread: 0.09, weight: 0.14),
            Cluster(cx: 0.44, cy: 0.36, spread: 0.10, weight: 0.08)
        ]
    }

    // MARK: - Daftar match

    static let matches: [MatchHistoryItem] = {
        let now = Date()
        let day: TimeInterval = 86_400

        func match(
            _ title: String,
            daysAgo: Double,
            goals: Int,
            assists: Int,
            distance: Double,
            clusters: [Cluster],
            count: Int
        ) -> MatchHistoryItem {
            let date = now.addingTimeInterval(-daysAgo * day)
            return MatchHistoryItem(
                title: title,
                date: date,
                goals: goals,
                assists: assists,
                totalDistanceMeters: distance,
                heatmapPoints: points(clusters: clusters, count: count, matchDate: date)
            )
        }

        return [
            match("Sunday League", daysAgo: 0, goals: 2, assists: 3,
                  distance: 6420, clusters: rightWinger, count: 420),
            match("Fun Match 3", daysAgo: 2, goals: 0, assists: 0,
                  distance: 4380, clusters: centreBack, count: 380),
            match("Fun Match 2", daysAgo: 6, goals: 1, assists: 2,
                  distance: 7150, clusters: centralMidfielder, count: 480),
            match("Fun Match 1", daysAgo: 9, goals: 4, assists: 1,
                  distance: 3920, clusters: striker, count: 300),
            match("Tarkam FC", daysAgo: 13, goals: 0, assists: 1,
                  distance: 5860, clusters: leftBack, count: 400)
        ]
    }()
}
