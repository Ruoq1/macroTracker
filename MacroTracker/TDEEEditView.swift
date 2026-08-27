import SwiftUI

/// Mirrors Apple's "Today's Move Goal" editor from the Activity app: a
/// full-height dark card with an X close button, a big stepped number, and a
/// pill confirm button at the bottom. Presented as a `.sheet` with
/// `.presentationDetents([.large])`, which gives the rounded top corners and
/// swipe-down-to-dismiss for free.
struct TDEEEditView: View {
    @Binding var tdee: Double
    @Environment(\.dismiss) private var dismiss

    private let step: Double = 50
    private let range: ClosedRange<Double> = 500...6000
    private let moveRed = Color(red: 0.99, green: 0.13, blue: 0.32)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.18), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 12)

            VStack(alignment: .leading, spacing: 10) {
                Text("Calorie Goal")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text("Set your maintenance calories (TDEE). Your surplus or deficit goal is calculated from this number.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.top, 28)

            Spacer()

            HStack(spacing: 36) {
                stepButton(systemImage: "minus") {
                    tdee = max(range.lowerBound, tdee - step)
                }
                Text(formatted(tdee))
                    .font(.system(size: 76, weight: .bold))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                stepButton(systemImage: "plus") {
                    tdee = min(range.upperBound, tdee + step)
                }
            }
            .frame(maxWidth: .infinity)

            Text("CALORIES/DAY")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)

            Spacer()
            Spacer()

            Text("This updates the maintenance calories used across the app.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.5))

            Button {
                dismiss()
            } label: {
                Text("Update Calorie Goal")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.12), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.black)
        .animation(.snappy, value: tdee)
        .sensoryFeedback(.selection, trigger: tdee)
    }

    private func stepButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(moveRed, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview {
    TDEEEditView(tdee: .constant(2000))
}
