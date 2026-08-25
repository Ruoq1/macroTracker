import SwiftUI

struct NutritionRow: View {
    let title: String
    let consumed: Double
    let goal: Double
    let unit: String
    var sizeScale: CGFloat = 1.0
    var onTap: (() -> Void)? = nil

    private var remaining: Double { goal - consumed }
    private var isOver: Bool { consumed > goal }
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(consumed / goal, 1.0)
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
                .tint(isOver ? .orange : .accentColor)

            Text(isOver ? "\(formatted(abs(remaining))) over" : "\(formatted(remaining)) left")
                .font(.subheadline)
                .foregroundStyle(isOver ? .orange : .secondary)
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
        NutritionRow(title: "Protein", consumed: 175, goal: 160, unit: "g", sizeScale: 1.5) {}
    }
    .padding()
}
