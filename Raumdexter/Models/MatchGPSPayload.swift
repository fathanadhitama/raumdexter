//
//  MatchGPSPayload.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 03/09/26.
//

struct MatchGPSPayload: Codable {
    let center: LocationSample
    let ownGoal: LocationSample
    let samples: [LocationSample]
    let goals: Int
    let assists: Int
    let distanceMeters: Double
}
