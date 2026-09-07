//
//  WatchLocationManager.swift
//  Raumdexter
//
//  Created by Fathan Naufal Adhitama on 03/09/26.
//

import CoreLocation
import Combine

@MainActor
final class WatchLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation?, Never>?
    private var onTrackingUpdate: ((CLLocation) -> Void)?
    
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 4 // meter, batas update supaya ga overload update tiap gerak
        manager.activityType = .fitness
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestOneShotLocation() async -> CLLocation? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }
    
    func startTracking(onUpdate: @escaping (CLLocation) -> Void) {
        onTrackingUpdate = onUpdate
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        onTrackingUpdate = nil
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            if let continuation {
                continuation.resume(returning: location)
                self.continuation = nil
            }
            onTrackingUpdate?(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            continuation?.resume(returning: nil)
            continuation = nil
        }
    }
}
