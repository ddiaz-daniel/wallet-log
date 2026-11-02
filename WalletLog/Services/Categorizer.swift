import Foundation
import SwiftData

enum Categorizer {
    /// Lowercased, diacritics folded, digits/punctuation replaced by spaces, whitespace collapsed.
    static func normalize(_ merchant: String) -> String {
        let folded = merchant.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).lowercased()
        let letters = folded.map { $0.isLetter ? $0 : " " }
        return String(letters).split(separator: " ").joined(separator: " ")
    }

    /// Rule key: the first word of the normalized merchant if it has >= 3 letters,
    /// otherwise the whole normalized string. "LIDL 1234 Wien" -> "lidl".
    static func key(for merchant: String) -> String {
        let normalized = normalize(merchant)
        guard let first = normalized.split(separator: " ").first else { return "" }
        return first.count >= 3 ? String(first) : normalized
    }

    private static let keywords: [(Category, [String])] = [
        (.groceries, ["lidl", "aldi", "rewe", "spar", "billa", "hofer", "carrefour", "mercadona", "supermarket"]),
        (.dining, ["restaurant", "cafe", "mcdonald", "burger", "pizza", "starbucks", "bar"]),
        (.transport, ["uber", "bolt", "shell", "omv", "bp", "parking", "obb", "db"]),
        (.health, ["apotheke", "pharmacy", "farmacia"]),
        (.shopping, ["amazon", "zara", "h&m", "ikea"]),
        (.entertainment, ["netflix", "spotify", "cinema", "kino"]),
        (.travel, ["hotel", "airbnb", "ryanair", "lufthansa"]),
    ]

    /// Keywords up to this length only match whole words ("bp", "db", "bar").
    private static let shortKeywordLength = 3

    private static func keywordCategory(for normalized: String) -> Category? {
        let padded = " \(normalized) "
        for (category, words) in keywords {
            for word in words {
                let kw = normalize(word)
                if kw.count <= shortKeywordLength {
                    if padded.contains(" \(kw) ") { return category }
                } else if normalized.contains(kw) {
                    return category
                }
            }
        }
        return nil
    }

    private static func rule(forKey key: String, context: ModelContext) -> MerchantRule? {
        var descriptor = FetchDescriptor<MerchantRule>(predicate: #Predicate { $0.merchantKey == key })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    /// Learned rule, then built-in keywords, then `.other`.
    static func category(for merchant: String, context: ModelContext) -> Category {
        let key = key(for: merchant)
        if !key.isEmpty, let rule = rule(forKey: key, context: context) { return rule.category }
        return keywordCategory(for: normalize(merchant)) ?? .other
    }

    /// Upserts the rule and re-categorizes other `.other` expenses with the same key.
    static func learn(merchant: String, category: Category, context: ModelContext) {
        let key = key(for: merchant)
        guard !key.isEmpty else { return }
        if let rule = rule(forKey: key, context: context) {
            rule.category = category
        } else {
            context.insert(MerchantRule(merchantKey: key, category: category))
        }
        guard category != .other else { return }
        let otherRaw = Category.other.rawValue
        let descriptor = FetchDescriptor<Expense>(predicate: #Predicate { $0.categoryRaw == otherRaw })
        for expense in (try? context.fetch(descriptor)) ?? [] where Self.key(for: expense.merchant) == key {
            expense.category = category
        }
    }
}
