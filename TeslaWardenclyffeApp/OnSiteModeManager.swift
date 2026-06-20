//
//  OnSiteModeManager.swift
//  TeslaWardenclyffeApp
//
//  On-site unlock manager (distance-based).
//  Swift 6 • iOS 17+
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class OnSiteModeManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    /// Tesla Science Center at Wardenclyffe (site)
    static let wardenclyffeCoordinate = CLLocationCoordinate2D(
        latitude: 40.948401,
        longitude: -72.898248
    )

    /// Adjust how strict “on-site” is.
    private let onSiteRadiusMeters: CLLocationDistance = 350

    private let locationManager = CLLocationManager()

    @Published var authorization: CLAuthorizationStatus = .notDetermined
    @Published var lastKnownLocation: CLLocation?
    @Published var distanceToSiteMeters: CLLocationDistance?
    @Published var isOnSite: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        refreshAuthorization()
    }

    func requestAccessIfNeeded() {
        refreshAuthorization()

        if authorization == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        startIfAuthorized()
    }

    func startIfAuthorized() {
        refreshAuthorization()
        guard authorization == .authorizedWhenInUse || authorization == .authorizedAlways else { return }
        locationManager.startUpdatingLocation()
    }

    func stop() {
        locationManager.stopUpdatingLocation()
    }

    private func refreshAuthorization() {
        // iOS 14+ instance property
        authorization = locationManager.authorizationStatus
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorization = manager.authorizationStatus
            self.startIfAuthorized()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        Task { @MainActor in
            self.lastKnownLocation = loc

            let site = CLLocation(
                latitude: Self.wardenclyffeCoordinate.latitude,
                longitude: Self.wardenclyffeCoordinate.longitude
            )

            let d = loc.distance(from: site)
            self.distanceToSiteMeters = d
            self.isOnSite = (d <= self.onSiteRadiusMeters)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Optional: you could publish an error string if you want UI messaging.
    }
}
