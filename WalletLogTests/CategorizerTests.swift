import XCTest
import SwiftData
@testable import WalletLog

@MainActor
final class CategorizerTests: XCTestCase {
    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: Expense.self, MerchantRule.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    func testKeywordMatch() throws {
        let ctx = try makeContext()
        XCTAssertEqual(Categorizer.category(for: "LIDL 1234 Wien", context: ctx), .groceries)
        XCTAssertEqual(Categorizer.category(for: "ÖBB Ticket", context: ctx), .transport)
        XCTAssertEqual(Categorizer.category(for: "H&M Store", context: ctx), .shopping)
        XCTAssertEqual(Categorizer.category(for: "Random Shop", context: ctx), .other)
    }

    func testShortKeywordsMatchWholeWordsOnly() throws {
        let ctx = try makeContext()
        XCTAssertEqual(Categorizer.category(for: "Barbershop", context: ctx), .other)
        XCTAssertEqual(Categorizer.category(for: "Wine Bar", context: ctx), .dining)
        XCTAssertEqual(Categorizer.category(for: "DB Bahn", context: ctx), .transport)
    }

    func testKeyNormalization() {
        XCTAssertEqual(Categorizer.key(for: "LIDL 1234 Wien"), "lidl")
        XCTAssertEqual(Categorizer.key(for: "  Café-Central!! "), "cafe")
        XCTAssertEqual(Categorizer.key(for: "H&M 12"), "h m")
        XCTAssertEqual(Categorizer.key(for: "123"), "")
    }

    func testLearnedRuleOverridesKeyword() throws {
        let ctx = try makeContext()
        Categorizer.learn(merchant: "Lidl Online", category: .shopping, context: ctx)
        XCTAssertEqual(Categorizer.category(for: "LIDL 99 Graz", context: ctx), .shopping)
        // Upsert changes the rule instead of duplicating it.
        Categorizer.learn(merchant: "lidl", category: .dining, context: ctx)
        XCTAssertEqual(Categorizer.category(for: "Lidl", context: ctx), .dining)
        XCTAssertEqual(try ctx.fetchCount(FetchDescriptor<MerchantRule>()), 1)
    }

    func testLearnRecategorizesOldOtherExpenses() throws {
        let ctx = try makeContext()
        let a = Expense(merchant: "Kebab Haus 1", amount: 5)
        let b = Expense(merchant: "KEBAB HAUS 2", amount: 6)
        let c = Expense(merchant: "Kebab Palace", amount: 7, category: .shopping)
        let d = Expense(merchant: "Other Place", amount: 8)
        [a, b, c, d].forEach { ctx.insert($0) }
        Categorizer.learn(merchant: "Kebab Haus", category: .dining, context: ctx)
        XCTAssertEqual(a.category, .dining)
        XCTAssertEqual(b.category, .dining)
        XCTAssertEqual(c.category, .shopping)
        XCTAssertEqual(d.category, .other)
    }
}
