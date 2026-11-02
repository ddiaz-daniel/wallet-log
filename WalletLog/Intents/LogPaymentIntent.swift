import AppIntents
import Foundation
import SwiftData

struct LogPaymentIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Payment"
    static let description = IntentDescription("Saves a Wallet payment with the current time and location.")
    static let openAppWhenRun = false

    @Parameter(title: "Merchant")
    var merchant: String

    @Parameter(title: "Amount")
    var amount: String

    @Parameter(title: "Card")
    var card: String?

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let parsed = AmountParser.parse(amount)
        let currency = parsed.currency ?? Expense.defaultCurrency
        let name = merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        let merchantName = name.isEmpty ? "Unknown" : name

        let location = await LocationService.shared.currentLocation()
        var address = ""
        if let location {
            address = await LocationService.shared.address(for: location) ?? ""
        }

        let expense = Expense(
            merchant: merchantName,
            amount: parsed.amount,
            currency: currency,
            card: card?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            category: Categorizer.category(for: merchantName, context: Store.container.mainContext),
            coordinate: location?.coordinate,
            address: address
        )
        let context = Store.container.mainContext
        context.insert(expense)
        try context.save()

        return .result(dialog: "Logged \(expense.formattedAmount) at \(merchantName)")
    }
}

struct WalletLogShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogPaymentIntent(),
            phrases: ["Log a payment in \(.applicationName)"],
            shortTitle: "Log Payment",
            systemImageName: "creditcard"
        )
    }
}
