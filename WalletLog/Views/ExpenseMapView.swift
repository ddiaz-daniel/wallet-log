import SwiftUI
import SwiftData
import MapKit

struct ExpenseMapView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var month = Date.now
    @State private var selection: PersistentIdentifier?
    @State private var editing: Expense?

    var body: some View {
        let located = MonthlySummary.filter(expenses, month: month).filter { $0.coordinate != nil }
        NavigationStack {
            VStack(spacing: 0) {
                MonthPicker(month: $month)
                if located.isEmpty {
                    ContentUnavailableView(
                        "No located expenses",
                        systemImage: "map",
                        description: Text("No expense with a location was logged in this month.")
                    )
                } else {
                    Map(selection: $selection) {
                        ForEach(located) { expense in
                            if let coordinate = expense.coordinate {
                                Marker(expense.merchant, systemImage: expense.category.symbol, coordinate: coordinate)
                                    .tint(expense.category.color)
                                    .tag(expense.persistentModelID)
                            }
                        }
                    }
                    .id(month)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selection) { _, id in
                guard let id, let expense = located.first(where: { $0.persistentModelID == id }) else { return }
                editing = expense
            }
            .sheet(item: $editing, onDismiss: { selection = nil }) { ExpenseEditView(expense: $0) }
        }
    }
}
