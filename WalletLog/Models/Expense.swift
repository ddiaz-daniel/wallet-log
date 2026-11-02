import Foundation
import SwiftData
import CoreLocation

@Model
final class Expense {
    var merchant: String
    var amount: Decimal
    var currency: String
    var card: String
    var date: Date
    var categoryRaw: String
    var note: String
    var latitude: Double?
    var longitude: Double?
    var address: String

    init(
        merchant: String,
        amount: Decimal,
        currency: String = Expense.defaultCurrency,
        card: String = "",
        date: Date = .now,
        category: Category = .other,
        note: String = "",
        coordinate: CLLocationCoordinate2D? = nil,
        address: String = ""
    ) {
        self.merchant = merchant
        self.amount = amount
        self.currency = currency
        self.card = card
        self.date = date
        self.categoryRaw = category.rawValue
        self.note = note
        self.latitude = coordinate?.latitude
        self.longitude = coordinate?.longitude
        self.address = address
    }

    static let defaultCurrency = "EUR"

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var formattedAmount: String {
        amount.formatted(.currency(code: currency))
    }
}

extension Decimal {
    var euros: String { formatted(.currency(code: Expense.defaultCurrency)) }
}
