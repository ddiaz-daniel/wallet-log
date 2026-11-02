import SwiftUI
import CoreLocation

struct SetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var status: CLAuthorizationStatus = .notDetermined

    private let steps = [
        "Open Shortcuts, go to Automation, tap + and choose Transaction.",
        "Select all cards and choose \"Run Immediately\".",
        "Add the action WalletLog > Log Payment.",
        "Map Merchant to Shortcut Input > Merchant, Amount to Shortcut Input > Amount, and Card to Shortcut Input > Card.",
        "Set WalletLog's location permission to Always.",
    ]

    private var statusText: String {
        switch status {
        case .authorizedAlways: "Always (ready)"
        case .authorizedWhenInUse: "While Using (change to Always)"
        case .denied: "Denied"
        case .restricted: "Restricted"
        case .notDetermined: "Not asked yet"
        @unknown default: "Unknown"
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Shortcuts setup") {
                    ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                        Label {
                            Text(step)
                        } icon: {
                            Image(systemName: "\(i + 1).circle.fill").foregroundStyle(.tint)
                        }
                    }
                }
                Section("Location permission") {
                    LabeledContent("Status", value: statusText)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                Section("Limitations") {
                    Text("Online and in-app Apple Pay purchases and refunds do not trigger the automation.")
                    Text("The location is the phone's position at payment time.")
                    Text("With a free developer account, re-install the app from Xcode every 7 days.")
                }
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") { dismiss() }
            }
            .onAppear { status = CLLocationManager().authorizationStatus }
        }
    }
}
