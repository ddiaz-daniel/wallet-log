import SwiftUI

enum Category: String, CaseIterable, Identifiable, Codable {
    case groceries, dining, transport, shopping, entertainment, health, bills, travel, other

    var id: String { rawValue }

    var label: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .groceries: "cart"
        case .dining: "fork.knife"
        case .transport: "car"
        case .shopping: "bag"
        case .entertainment: "film"
        case .health: "cross.case"
        case .bills: "doc.text"
        case .travel: "airplane"
        case .other: "questionmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .groceries: .green
        case .dining: .orange
        case .transport: .blue
        case .shopping: .pink
        case .entertainment: .purple
        case .health: .red
        case .bills: .brown
        case .travel: .teal
        case .other: .gray
        }
    }
}
