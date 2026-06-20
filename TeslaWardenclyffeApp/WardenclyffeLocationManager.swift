// WardenclyffeLocationManager.swift

import Foundation
import CoreLocation
import Combine

final class WardenclyffeLocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var isOnSite: Bool = false
    @Published var lastErrorDescription: String?

    private let manager = CLLocationManager()

    /// Approximate center of Tesla Science Center at Wardenclyffe
    /// 5 Randall Road, Shoreham, NY 11786
    private let siteLocation = CLLocation(latitude: 40.947810, longitude: -72.900000)

    /// Radius in meters considered “on site”
    private let siteRadius: CLLocationDistance = 300

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestAccessIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            lastErrorDescription = "Location access is disabled. Turn it on in Settings to unlock full on-site AR features."
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    private func updateOnSiteFlag(for location: CLLocation?) {
        guard let location else {
            isOnSite = false
            return
        }
        let distance = location.distance(from: siteLocation)
        isOnSite = distance <= siteRadius
    }
}

extension WardenclyffeLocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            lastErrorDescription = "Location access is disabled. Turn it on in Settings to unlock full on-site AR features."
            isOnSite = false
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latest = locations.last else { return }
        currentLocation = latest
        updateOnSiteFlag(for: latest)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        lastErrorDescription = error.localizedDescription
    }
}
