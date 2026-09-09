//
//  WatchAppViewModel.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 03/09/26.
//

import Foundation
import Combine
import CoreLocation

/// Hasil akhir dari upaya nyimpen match, ditampilin ke user setelah tap End Match.
enum MatchSaveStatus: Equatable {
    case idle
    case sending
    /// iPhone reachable dan konfirmasi tersimpan.
    case success
    /// iPhone gak reachable — dikirim via antrean background, TIDAK terkonfirmasi.
    case queued
    case failed(String)
}

internal class WatchAppViewModel: ObservableObject {
    @Published var appState: AppState = .initial
    @Published var fieldCenter: LocationSample?
    @Published var ownGoal: LocationSample?
    @Published var matchSamples: [LocationSample] = []
    @Published var goals: Int = 0
    @Published var assists: Int = 0
    @Published var distanceCoveredMeters: Double = 0
    @Published var matchStartDate: Date?

    /// Lagi nunggu fix GPS (bisa beberapa detik) — dipakai buat spinner & disable tombol.
    @Published private(set) var isRequestingLocation = false
    /// Lagi ngirim data match ke iPhone.
    @Published private(set) var isEndingMatch = false
    /// Pesan error terakhir, misal GPS gagal dapat sinyal.
    @Published var errorMessage: String?
    /// Status pengiriman match setelah tap End — dipakai buat layar hasil (sukses/gagal/antre).
    @Published private(set) var saveStatus: MatchSaveStatus = .idle

    private var lastTrackedLocation: CLLocation?

    var locationManager: WatchLocationManager = WatchLocationManager()
    var connector: WatchToiOSConnector = WatchToiOSConnector()

    var distanceCoveredText: String {
        if distanceCoveredMeters < 1000 {
            "\(Int(distanceCoveredMeters)) m"
        } else {
            String(format: "%.2f km", distanceCoveredMeters / 1000)
        }
    }

    var isLocationDenied: Bool {
        locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted
    }

    // MARK: - Flow

    func startMatch() {
        errorMessage = nil
        appState = .fieldProjecting
    }

    func submitFieldCenter() async {
        guard !isRequestingLocation else { return }

        isRequestingLocation = true
        errorMessage = nil
        defer { isRequestingLocation = false }

        guard let location = await locationManager.requestOneShotLocation() else {
            errorMessage = "Gagal dapat sinyal GPS. Coba lagi di area terbuka."
            return
        }

        fieldCenter = LocationSample(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp
        )
        appState = .settingGoalDirection
    }

    func submitOwnGoalDirection() async {
        guard !isRequestingLocation else { return }

        isRequestingLocation = true
        errorMessage = nil
        defer { isRequestingLocation = false }

        guard let location = await locationManager.requestOneShotLocation() else {
            errorMessage = "Gagal dapat sinyal GPS. Coba lagi di area terbuka."
            return
        }

        ownGoal = LocationSample(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp
        )
        appState = .tracking
        startTrackingGPS()
    }

    func cancelMatch() {
        locationManager.stopTracking()
        resetMatchState()
    }

    // MARK: - Counters

    func incrementGoal() { goals += 1 }
    func decrementGoal() { goals = max(0, goals - 1) }
    func incrementAssist() { assists += 1 }
    func decrementAssist() { assists = max(0, assists - 1) }

    // MARK: - Tracking

    func startTrackingGPS() {
        // taking user's gps while in match to make heatmap
        matchSamples = []
        distanceCoveredMeters = 0
        lastTrackedLocation = nil
        matchStartDate = Date()

        locationManager.startTracking { [weak self] location in
            guard let self else { return }

            // Buang fix yang akurasinya jelek banget (negatif = tidak valid, atau lingkaran error > 20m)
            // — daripada nambahin noise ke heatmap & itungan jarak.
//            guard location.horizontalAccuracy >= 0, location.horizontalAccuracy <= 20 else { return }

            if let last = self.lastTrackedLocation {
                let distance = location.distance(from: last)
                // Cuma dianggap gerakan beneran kalau jaraknya lebih jauh dari radius error GPS
                // kedua titik — di bawah itu, kemungkinan besar cuma GPS jitter, bukan gerakan asli.
                let noiseThreshold = max(last.horizontalAccuracy, location.horizontalAccuracy)
                if distance > noiseThreshold {
                    self.distanceCoveredMeters += distance
                    self.lastTrackedLocation = location
                }
            } else {
                self.lastTrackedLocation = location
            }

            self.matchSamples.append(
                LocationSample(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    timestamp: location.timestamp
                )
            )
        }
    }

    func endMatch() {
        guard !isEndingMatch else { return }
        locationManager.stopTracking()
        Task { await sendMatch() }
    }

    /// Dipanggil ulang dari layar hasil kalau pengiriman sebelumnya gagal.
    /// Data match (samples, gol, assist, jarak) masih utuh — gak perlu main ulang.
    func retrySendMatch() {
        guard !isEndingMatch else { return }
        Task { await sendMatch() }
    }

    /// User pilih buang match yang gagal terkirim, daripada terus nyoba.
    func discardFailedMatch() {
        resetMatchState()
    }

    /// User udah liat hasil sukses/antre, lanjut balik ke layar awal.
    func acknowledgeSaveResult() {
        resetMatchState()
    }

    private func sendMatch() async {
        isEndingMatch = true
        saveStatus = .sending
        defer { isEndingMatch = false }

        guard let fieldCenter, let ownGoal else {
            saveStatus = .failed("Data kalibrasi lapangan hilang, match tidak bisa disimpan.")
            return
        }

        let result = await connector.sendMatchData(
            center: fieldCenter,
            ownGoal: ownGoal,
            samples: matchSamples,
            goals: goals,
            assists: assists,
            distanceMeters: distanceCoveredMeters
        )

        switch result {
        case .success:
            saveStatus = .success
        case .queued:
            saveStatus = .queued
        case .failure(let message):
            saveStatus = .failed(message)
        }
    }

    private func resetMatchState() {
        saveStatus = .idle
        appState = .initial
        matchSamples = []
        goals = 0
        assists = 0
        distanceCoveredMeters = 0
        matchStartDate = nil
        lastTrackedLocation = nil
        fieldCenter = nil
        ownGoal = nil
    }
}
