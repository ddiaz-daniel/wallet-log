import SwiftUI

@main
struct WalletLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Store.container)
    }
}

struct ContentView: View {
    @AppStorage("selectedTab") private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ExpenseListView()
                .tabItem { Label("Expenses", systemImage: "list.bullet") }
                .tag(0)
            SummaryView()
                .tabItem { Label("Summary", systemImage: "chart.pie") }
                .tag(1)
            ExpenseMapView()
                .tabItem { Label("Map", systemImage: "map") }
                .tag(2)
        }
        .onAppear {
            LocationService.shared.requestPermission()
            #if DEBUG
            SampleData.seedIfRequested()
            #endif
        }
    }
}
