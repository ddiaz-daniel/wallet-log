import SwiftUI

/// ‹ November 2026 › selector shared by Summary and Map.
struct MonthPicker: View {
    @Binding var month: Date

    var body: some View {
        HStack {
            Button { shift(-1) } label: { Image(systemName: "chevron.left") }
            Spacer()
            Text(month, format: .dateTime.month(.wide).year()).font(.headline)
            Spacer()
            Button { shift(1) } label: { Image(systemName: "chevron.right") }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func shift(_ delta: Int) {
        month = Calendar.current.date(byAdding: .month, value: delta, to: month) ?? month
    }
}
