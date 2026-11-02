import XCTest
@testable import WalletLog

final class AmountParserTests: XCTestCase {
    private func check(_ text: String, _ amount: String, _ currency: String?, line: UInt = #line) {
        let r = AmountParser.parse(text)
        XCTAssertEqual(r.amount, Decimal(string: amount)!, text, line: line)
        XCTAssertEqual(r.currency, currency, text, line: line)
    }

    func testFormats() {
        check("€12,50", "12.50", "EUR")
        check("12.50 €", "12.50", "EUR")
        check("1.234,56 €", "1234.56", "EUR")
        check("$1,234.56", "1234.56", "USD")
        check("EUR 3", "3", "EUR")
        check("-4,00", "-4.00", nil)
        check("£1,234", "1234", "GBP")
        check("1.234.567", "1234567", nil)
    }

    func testEmptyIsZero() {
        check("", "0", nil)
    }
}
