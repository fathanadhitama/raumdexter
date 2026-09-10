//
//  PlayerProfile.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 01/09/26.
//

import Foundation
import SwiftData

/// Profil pemain. Cuma ada satu record di database — dibikin otomatis dengan
/// nilai default kalau user belum pernah nyetel apa pun.
@Model
final class PlayerProfile {
    var name: String
    var jerseyNumber: Int

    /// Foto disimpan sebagai file terpisah (bukan inline di database) biar
    /// query profil tetap ringan walau fotonya gede.
    @Attribute(.externalStorage)
    var photoData: Data?

    init(name: String = PlayerProfile.defaultName, jerseyNumber: Int = PlayerProfile.defaultJerseyNumber, photoData: Data? = nil) {
        self.name = name
        self.jerseyNumber = jerseyNumber
        self.photoData = photoData
    }

    static let defaultName = "Pemain"
    static let defaultJerseyNumber = 10

    /// Batas wajar biar layout hero-nya nggak jebol.
    static let maxNameLength = 18
    static let jerseyNumberRange = 0...99
}
