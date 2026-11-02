import XCTest
@testable import WalletLog

final class ExpenseTests: XCTestCase {
    func testCategoryFallsBackToOther() {
        let expense = Expense(merchant: "Test", amount: 1)
        expense.categoryRaw = "unknown"
        XCTAssertEqual(expense.category, .other)
    }
}
