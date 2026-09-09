//
//  WatchTheme.swift
//  Raumdexter Watch App
//
//  Created by Fathan Naufal Adhitama on 08/09/26.
//

import SwiftUI

/// Token warna watch app — disamain sama tema iOS (gelap kebiruan, aksen biru elektrik).
enum WatchTheme {
    static let background = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let surface = Color(red: 0.10, green: 0.11, blue: 0.16)
    static let surfaceElevated = Color(red: 0.15, green: 0.16, blue: 0.22)

    static let accent = Color(red: 0.24, green: 0.48, blue: 1.00)
    static let success = Color(red: 0.22, green: 0.84, blue: 0.48)
    static let danger = Color(red: 1.00, green: 0.30, blue: 0.37)

    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.55)
    static let tertiaryText = Color.white.opacity(0.35)
}
