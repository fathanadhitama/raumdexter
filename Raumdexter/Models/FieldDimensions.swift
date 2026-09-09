//
//  FieldDimensions.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 07/09/26.
//

import Foundation

/// Ukuran lapangan dalam meter. Dipakai bareng-bareng oleh kalibrasi GPS
/// (`GPSPoint.calibrated`) dan gambar lapangan di heatmap, supaya proporsinya
/// selalu konsisten antara data dan visual.
struct FieldDimensions {
    let lengthMeters: Double
    let widthMeters: Double

    /// Perbandingan panjang : lebar — dipakai sebagai aspect ratio view heatmap.
    var aspectRatio: Double { lengthMeters / widthMeters }

    static let miniSoccer = FieldDimensions(lengthMeters: 42, widthMeters: 25)
    static let standard = FieldDimensions(lengthMeters: 105, widthMeters: 68)
}
