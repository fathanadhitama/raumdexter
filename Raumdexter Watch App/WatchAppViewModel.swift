//
//  WatchAppViewModel.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 03/09/26.
//

import Foundation
import Combine
import CoreLocation

internal class WatchAppViewModel: ObservableObject {
    @Published var appState: AppState = .initial
    @Published var fieldCenter: LocationSample?
    @Published var ownGoal: LocationSample?
    @Published var matchSamples: [LocationSample] = []
    @Published var goals: Int = 0
    @Published var assists: Int = 0
    @Published var distanceCoveredMeters: Double = 0

    private var lastTrackedLocation: CLLocation?

    var locationManager: WatchLocationManager = WatchLocationManager()
    var connector: WatchToiOSConnector = WatchToiOSConnector()

    var distanceCoveredText: String {
        String(format: "%.1fkm", distanceCoveredMeters / 1000)
    }

    func startMatch() {
        print("Match started")
        appState = .fieldProjecting
    }

    func submitFieldCenter() async {
        print("Submitting field center...")
        guard let location = await locationManager.requestOneShotLocation() else { return }
        fieldCenter = LocationSample(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp
        )
        print("Field center: \(fieldCenter, default: "nil")")
        appState = .settingGoalDirection
    }

    func submitOwnGoalDirection() async {
        print("Submitting own goal direction...")
        guard let location = await locationManager.requestOneShotLocation() else { return }
        ownGoal = LocationSample(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp
        )
        print("Own goal: \(ownGoal, default: "nil")")
        appState = .tracking
        startTrackingGPS()
    }

    func incrementGoal() { goals += 1 }
    func decrementGoal() { goals = max(0, goals - 1) }
    func incrementAssist() { assists += 1 }
    func decrementAssist() { assists = max(0, assists - 1) }

    func startTrackingGPS() {
        // taking user's gps while in match to make heatmap
        matchSamples = []
        distanceCoveredMeters = 0
        lastTrackedLocation = nil
        locationManager.startTracking { [weak self] location in
            guard let self else { return }
            print("Tracking location \(location.coordinate.latitude), \(location.coordinate.longitude)")
            if let last = self.lastTrackedLocation {
                print("Distance: \(location.distance(from: last))")
                self.distanceCoveredMeters += location.distance(from: last)
            }
            self.lastTrackedLocation = location
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
        print("End match")
        locationManager.stopTracking()
        guard let fieldCenter, let ownGoal else { return }
        print("Sending match data")
        connector.sendMatchData(
            center: fieldCenter,
            ownGoal: ownGoal,
            samples: matchSamples,
            goals: goals,
            assists: assists,
            distanceMeters: distanceCoveredMeters
        )
        appState = .initial
        matchSamples = []
        goals = 0
        assists = 0
        distanceCoveredMeters = 0
        self.fieldCenter = nil
        self.ownGoal = nil
    }
}
