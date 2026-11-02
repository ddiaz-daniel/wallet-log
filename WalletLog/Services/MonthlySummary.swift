import Foundation

/// Pure grouping/sum logic for one calendar month of expenses.
struct MonthlySummary {
    struct CategoryTotal: Identifiable {
        let category: Category
        let total: Decimal
        let count: Int
        /// Share of the month's total, 0...1.
        let share: Double
        var id: Category { category }
    }

    let expenses: [Expense]
    let total: Decimal
    let categories: [CategoryTotal]

    init(expenses all: [Expense], month: Date, calendar: Calendar = .current) {
        self.expenses = MonthlySummary.filter(all, month: month, calendar: calendar)
        total = expenses.reduce(Decimal.zero) { $0 + $1.amount }
        let grouped = Dictionary(grouping: expenses, by: \.category)
        let totalValue = NSDecimalNumber(decimal: total).doubleValue
        categories = grouped.map { category, items in
            let sum = items.reduce(Decimal.zero) { $0 + $1.amount }
            let share = totalValue > 0 ? NSDecimalNumber(decimal: sum).doubleValue / totalValue : 0
            return CategoryTotal(category: category, total: sum, count: items.count, share: share)
        }
        .sorted { $0.total != $1.total ? $0.total > $1.total : $0.category.rawValue < $1.category.rawValue }
    }

    static func filter(_ expenses: [Expense], month: Date, calendar: Calendar = .current) -> [Expense] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        return expenses
            .filter { interval.contains($0.date) }
            .sorted { $0.date > $1.date }
    }
}
