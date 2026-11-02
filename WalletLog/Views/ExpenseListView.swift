import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var search = ""
    @State private var editing: Expense?
    @State private var adding = false

    private var filtered: [Expense] {
        guard !search.isEmpty else { return expenses }
        return expenses.filter {
            $0.merchant.localizedCaseInsensitiveContains(search)
                || $0.note.localizedCaseInsensitiveContains(search)
                || $0.address.localizedCaseInsensitiveContains(search)
                || $0.category.label.localizedCaseInsensitiveContains(search)
        }
    }

    private var days: [(day: Date, items: [Expense])] {
        Dictionary(grouping: filtered) { Calendar.current.startOfDay(for: $0.date) }
            .sorted { $0.key > $1.key }
            .map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(days, id: \.day) { day, items in
                    Section {
                        ForEach(items) { expense in
                            Button { editing = expense } label: { ExpenseRow(expense: expense) }
                                .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            offsets.forEach { context.delete(items[$0]) }
                        }
                    } header: {
                        HStack {
                            Text(day, format: .dateTime.weekday(.wide).day().month())
                            Spacer()
                            Text(items.reduce(Decimal.zero) { $0 + $1.amount }.euros)
                        }
                    }
                }
            }
            .overlay {
                if expenses.isEmpty {
                    ContentUnavailableView(
                        "No expenses yet",
                        systemImage: "creditcard",
                        description: Text("Pay with Apple Pay once the Shortcuts automation is set up, or add one with +.")
                    )
                }
            }
            .searchable(text: $search)
            .navigationTitle("Expenses")
            .toolbar {
                Button { adding = true } label: { Image(systemName: "plus") }
            }
            .sheet(item: $editing) { ExpenseEditView(expense: $0) }
            .sheet(isPresented: $adding) { ExpenseEditView(expense: nil) }
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.symbol)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(expense.category.color, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.merchant).font(.body)
                Text([expense.date.formatted(date: .omitted, time: .shortened), expense.address]
                    .filter { !$0.isEmpty }
                    .joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(expense.formattedAmount).font(.body.monospacedDigit())
        }
        .contentShape(Rectangle())
    }
}
