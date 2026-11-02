import XCTest
@testable import WalletLog

final class MonthlySummaryTests: XCTestCase {
    private let cal = Calendar(identifier: .gregorian)

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d, hour: 12))!
    }

    func testFiltersTotalsAndSorts() {
        let expenses = [
            Expense(merchant: "A", amount: 10, date: date(2026, 5, 3), category: .dining),
            Expense(merchant: "B", amount: 30, date: date(2026, 5, 31), category: .groceries),
            Expense(merchant: "C", amount: 20, date: date(2026, 5, 10), category: .dining),
            Expense(merchant: "D", amount: 99, date: date(2026, 6, 1), category: .travel),
        ]
        let s = MonthlySummary(expenses: expenses, month: date(2026, 5, 15), calendar: cal)
        XCTAssertEqual(s.expenses.count, 3)
        XCTAssertEqual(s.total, 60)
        XCTAssertEqual(s.categories.map(\.category), [.dining, .groceries])
        XCTAssertEqual(s.categories[0].total, 30)
        XCTAssertEqual(s.categories[0].share, 0.5, accuracy: 0.0001)
        XCTAssertEqual(s.categories.reduce(0) { $0 + $1.share }, 1, accuracy: 0.0001)
    }

    func testEmptyMonth() {
        let s = MonthlySummary(expenses: [], month: date(2026, 5, 1), calendar: cal)
        XCTAssertEqual(s.total, 0)
        XCTAssertTrue(s.categories.isEmpty)
    }
}
