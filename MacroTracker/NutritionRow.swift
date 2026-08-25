import SwiftUI

struct NutritionRow: View {
    let title: String
    let consumed: Double
    let goal: Double
    let unit: String
    var sizeScale: CGFloat = 1.0
    var lowThreshold: Double? = nil
    var lowColor: Color = .red
    var statusReference: Double? = nil
    var overLabel: String = "over"
    var underLabel: String = "left"
    var isOverOverride: Bool? = nil
    var onTap: (() -> Void)? = nil

    private var isOver: Bool { isOverOverride ?? (consumed > goal) }
    private var referenceBase: Double { statusReference ?? goal }
    private var referenceRemaining: Double { referenceBase - consumed }
    private var isOverReference: Bool { consumed > referenceBase }
    private var isLow: Bool {
        guard let lowThreshold, goal > 0, !isOver else { return false }
        return consumed / goal < lowThreshold
    }
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(consumed / goal, 1.0)
    }
    private var statusColor: Color? {
        if isOver { return .orange }
        if isLow { return lowColor }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            if let onTap {
                Button(action: onTap) {
                    numberRow
                }
                .buttonStyle(.plain)
            } else {
                numberRow
            }

            ProgressView(value: progress)
                .tint(statusColor ?? .accentColor)

            Text(isOverReference ? "\(formatted(abs(referenceRemaining))) \(overLabel)" : "\(formatted(referenceRemaining)) \(underLabel)")
                .font(.subheadline)
                .foregroundStyle(statusColor ?? .secondary)
        }
        .padding(.vertical, 4)
    }

    private var numberRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(formatted(consumed))
                .font(.system(size: 28 * sizeScale, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text("/ \(formatted(goal))\(unit.isEmpty ? "" : " " + unit)")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview {
    VStack(spacing: 32) {
        NutritionRow(title: "Calories", consumed: 1420, goal: 2000, unit: "", sizeScale: 1.0)
        NutritionRow(title: "Protein", consumed: 175, goal: 160, unit: "g", sizeScale: 1.5, lowThreshold: 0.3) {}
        NutritionRow(title: "Carbs", consumed: 30, goal: 180, unit: "g", sizeScale: 1.5, lowThreshold: 0.3) {}
    }
    .padding()
}
