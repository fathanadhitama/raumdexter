//
//  PlayerProfile.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

struct PlayerProfile {
    let name: String
    let jerseyNumber: Int
    let photoName: String   // asset name di Assets.xcassets, fallback ke system image kalau kosong
    let totalMatches: Int
    let totalGoals: Int
    let totalAssists: Int
    let avgDistanceKm: Double
}
