import Foundation
import SwiftData

/// A learned merchant -> category mapping (see `Categorizer.key(for:)`).
@Model
final class MerchantRule {
    @Attribute(.unique) var merchantKey: String
    var categoryRaw: String

    init(merchantKey: String, category: Category) {
        self.merchantKey = merchantKey
        self.categoryRaw = category.rawValue
    }

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}
