import SwiftUI
import SwiftData
import MapKit

/// Edits an existing expense, or creates a new one when `expense` is nil.
struct ExpenseEditView: View {
    let expense: Expense?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var merchant: String
    @State private var amount: Decimal
    @State private var date: Date
    @State private var category: Category
    @State private var card: String
    @State private var note: String

    init(expense: Expense?) {
        self.expense = expense
        _merchant = State(initialValue: expense?.merchant ?? "")
        _amount = State(initialValue: expense?.amount ?? 0)
        _date = State(initialValue: expense?.date ?? .now)
        _category = State(initialValue: expense?.category ?? .other)
        _card = State(initialValue: expense?.card ?? "")
        _note = State(initialValue: expense?.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Merchant", text: $merchant)
                    TextField("Amount", value: $amount, format: .number)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date)
                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases) { Label($0.label, systemImage: $0.symbol).tag($0) }
                    }
                }
                Section {
                    TextField("Card", text: $card)
                    TextField("Note", text: $note, axis: .vertical)
                }
                if let expense, let coordinate = expense.coordinate {
                    Section("Location") {
                        if !expense.address.isEmpty { Text(expense.address) }
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: coordinate,
                            latitudinalMeters: 500,
                            longitudinalMeters: 500
                        ))) {
                            Marker(expense.merchant, coordinate: coordinate)
                        }
                        .frame(height: 180)
                        .listRowInsets(EdgeInsets())
                    }
                }
            }
            .navigationTitle(expense == nil ? "New Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(merchant.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let isNew = expense == nil
        let previous = expense?.category
        let name = merchant.trimmingCharacters(in: .whitespaces)
        var chosen = category
        if isNew && chosen == .other {
            chosen = Categorizer.category(for: name, context: context)
        }
        let target = expense ?? {
            let new = Expense(merchant: "", amount: 0)
            context.insert(new)
            return new
        }()
        target.merchant = name
        target.amount = amount
        target.date = date
        target.category = chosen
        target.card = card
        target.note = note
        let userChose = isNew ? category != .other : chosen != previous
        if userChose {
            Categorizer.learn(merchant: name, category: chosen, context: context)
        }
        dismiss()
    }
}
