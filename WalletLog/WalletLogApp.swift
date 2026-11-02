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
    var body: some View {
        TabView {
            ExpenseListView()
                .tabItem { Label("Expenses", systemImage: "list.bullet") }
        }
    }
}
