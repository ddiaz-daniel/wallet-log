import Foundation

/// Parses free-form amount text sent by Shortcuts (e.g. "€12,50", "1.234,56 €", "$1,234.56").
enum AmountParser {
    static func parse(_ text: String) -> (amount: Decimal, currency: String?) {
        let upper = text.uppercased()
        var currency: String?
        if text.contains("€") || upper.contains("EUR") { currency = "EUR" }
        else if text.contains("$") || upper.contains("USD") { currency = "USD" }
        else if text.contains("£") || upper.contains("GBP") { currency = "GBP" }

        var s = text.filter { $0.isASCII && ($0.isNumber || $0 == "," || $0 == "." || $0 == "-") }
        let negative = s.hasPrefix("-")
        s = s.replacingOccurrences(of: "-", with: "")

        let lastComma = s.lastIndex(of: ",")
        let lastDot = s.lastIndex(of: ".")
        let commas = s.filter { $0 == "," }.count
        let dots = s.filter { $0 == "." }.count

        var decimalSep: Character?
        if let c = lastComma, let d = lastDot {
            decimalSep = c > d ? "," : "."
        } else if let c = lastComma {
            let after = s.distance(from: c, to: s.endIndex) - 1
            if commas == 1 && after <= 2 { decimalSep = "," }
        } else if lastDot != nil, dots == 1 {
            decimalSep = "."
        }

        var normalized = s.filter { $0.isNumber }
        // Only the last decimal separator should survive.
        if let sep = decimalSep {
            let idx = s.lastIndex(of: sep)!
            let intPart = s[..<idx].filter { $0.isNumber }
            let frac = s[s.index(after: idx)...].filter { $0.isNumber }
            normalized = intPart + (frac.isEmpty ? "" : "." + frac)
        }

        guard !normalized.isEmpty,
              let value = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
        else { return (0, currency) }
        return (negative ? -value : value, currency)
    }
}
