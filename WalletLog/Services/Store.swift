import SwiftData

/// One container shared by the UI and App Intents (both run in the app process).
enum Store {
    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: Expense.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
