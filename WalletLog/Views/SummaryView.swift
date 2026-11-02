import SwiftUI
import SwiftData
import Charts

struct SummaryView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var month = Date.now

    var body: some View {
        let summary = MonthlySummary(expenses: expenses, month: month)
        NavigationStack {
            VStack(spacing: 0) {
                MonthPicker(month: $month)
                if summary.expenses.isEmpty {
                    ContentUnavailableView(
                        "No expenses this month",
                        systemImage: "chart.pie",
                        description: Text("Nothing was logged in this month.")
                    )
                } else {
                    List {
                        Section {
                            VStack(spacing: 4) {
                                Chart(summary.categories) {
                                    SectorMark(
                                        angle: .value("Amount", NSDecimalNumber(decimal: $0.total).doubleValue),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 1.5
                                    )
                                    .foregroundStyle($0.category.color)
                                }
                                .frame(height: 220)
                                .chartBackground { _ in
                                    VStack {
                                        Text("Total").font(.caption).foregroundStyle(.secondary)
                                        Text(summary.total.euros).font(.title2.bold())
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        Section("Categories") {
                            ForEach(summary.categories) { item in
                                NavigationLink {
                                    CategoryExpensesView(category: item.category, expenses: summary.expenses)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: item.category.symbol)
                                            .foregroundStyle(.white)
                                            .frame(width: 32, height: 32)
                                            .background(item.category.color, in: Circle())
                                        Text(item.category.label)
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(item.total.euros).monospacedDigit()
                                            Text(item.share, format: .percent.precision(.fractionLength(0)))
                                                .font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CategoryExpensesView: View {
    let category: Category
    let expenses: [Expense]
    @State private var editing: Expense?

    var body: some View {
        List(expenses.filter { $0.category == category }) { expense in
            Button { editing = expense } label: { ExpenseRow(expense: expense) }
                .buttonStyle(.plain)
        }
        .navigationTitle(category.label)
        .sheet(item: $editing) { ExpenseEditView(expense: $0) }
    }
}
