import CoreLocation
import Foundation

@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation?, Never>?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }

    private var isDenied: Bool {
        manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted
    }

    func currentLocation(timeout: TimeInterval = 8) async -> CLLocation? {
        if isDenied { return nil }
        if let cached = manager.location, abs(cached.timestamp.timeIntervalSinceNow) < 60 {
            return cached
        }
        // A request is already in flight: finish it with the best we have.
        finish(manager.location)

        let location: CLLocation? = await withCheckedContinuation { cont in
            continuation = cont
            manager.requestLocation()
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                self?.finish(self?.manager.location)
            }
        }
        return location
    }

    /// Resumes the pending continuation at most once (delegate vs. timeout race).
    private func finish(_ location: CLLocation?) {
        guard let cont = continuation else { return }
        continuation = nil
        cont.resume(returning: location)
    }

    func address(for location: CLLocation) async -> String? {
        let placemarks = try? await CLGeocoder().reverseGeocodeLocation(location)
        guard let p = placemarks?.first else { return nil }
        let parts = [p.name, p.locality].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    // MARK: CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let last = locations.last
        Task { @MainActor in self.finish(last) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in self.finish(nil) }
    }
}
