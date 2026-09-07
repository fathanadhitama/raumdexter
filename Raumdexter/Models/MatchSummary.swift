//
//  MatchSummary.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//
import Foundation

struct MatchSummary: Identifiable {
    let id = UUID()
    let title: String
    let heatmapPoints: [GPSPoint]   // asset heatmap, fallback placeholder kalau kosong
    let date: Date
}
