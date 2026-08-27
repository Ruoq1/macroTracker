import SwiftUI

/// Mirrors Apple's "Today's Move Goal" editor from the Activity app: a
/// full-height card with an X close button, a big stepped number, and a
/// pill confirm button at the bottom. Presented as a `.sheet` with
/// `.presentationDetents([.large])`, which gives the rounded top corners and
/// swipe-down-to-dismiss for free. Uses semantic colors throughout (unlike
/// Apple's version, which stays black even in Light Mode) so it follows the
/// rest of the app's light/dark appearance. Reused for the calorie goal
/// (TDEE) and each macro goal, distinguished only by the accent color on the
/// +/- steppers.
struct GoalStepperEditView: View {
    let title: String
    let description: String
    let unitLabel: String
    let footer: String
    let confirmLabel: String
    @Binding var value: Double
    var step: Double
    var range: ClosedRange<Double>
    var accentColor: Color

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 12)

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 28)

            Spacer()

            HStack(spacing: 36) {
                stepButton(systemImage: "minus") {
                    value = max(range.lowerBound, value - step)
                }
                Text(formatted(value))
                    .font(.system(size: 76, weight: .bold))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                stepButton(systemImage: "plus") {
                    value = min(range.upperBound, value + step)
                }
            }
            .frame(maxWidth: .infinity)

            Text(unitLabel)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)

            Spacer()
            Spacer()

            Text(footer)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button {
                dismiss()
            } label: {
                Text(confirmLabel)
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray5), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .animation(.snappy, value: value)
        .sensoryFeedback(.selection, trigger: value)
    }

    private func stepButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(accentColor, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview {
    GoalStepperEditView(
        title: "Calorie Goal",
        description: "Set your maintenance calories (TDEE).",
        unitLabel: "CALORIES/DAY",
        footer: "This updates the maintenance calories used across the app.",
        confirmLabel: "Update Calorie Goal",
        value: .constant(2000),
        step: 50,
        range: 500...6000,
        accentColor: Color(red: 0.99, green: 0.13, blue: 0.32)
    )
}
