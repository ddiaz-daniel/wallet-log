#if DEBUG
import Foundation
import SwiftData
import CoreLocation

/// Debug-only: launch with `-seedSampleData` to fill an empty store around Vienna.
enum SampleData {
    @MainActor
    static func seedIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-seedSampleData") else { return }
        let context = Store.container.mainContext
        guard (try? context.fetchCount(FetchDescriptor<Expense>())) == 0 else { return }
        let rows: [(String, Decimal, Category, Double, Double)] = [
            ("Billa", 23.40, .groceries, 0.002, 0.001),
            ("Spar", 41.15, .groceries, -0.004, 0.006),
            ("Cafe Central", 12.80, .dining, 0.001, -0.003),
            ("Burger Place", 18.90, .dining, -0.002, -0.006),
            ("Wiener Linien", 28.50, .transport, 0.005, 0.004),
            ("Zara", 79.99, .shopping, 0.003, -0.001),
            ("Cinema", 14.00, .entertainment, -0.006, 0.002),
            ("Apotheke", 9.70, .health, 0.004, -0.005),
            ("A1 Mobile", 25.00, .bills, 0, 0),
            ("Hotel Sacher", 210.00, .travel, -0.001, 0.003),
            ("Misc", 5.00, .other, 0.006, 0.007),
        ]
        for (i, row) in rows.enumerated() {
            let located = row.0 != "A1 Mobile"
            context.insert(Expense(
                merchant: row.0, amount: row.1,
                date: Calendar.current.date(byAdding: .hour, value: -i * 5, to: .now) ?? .now,
                category: row.2,
                coordinate: located ? CLLocationCoordinate2D(latitude: 48.2082 + row.3, longitude: 16.3738 + row.4) : nil,
                address: located ? "Vienna" : ""
            ))
        }
    }
}
#endif
