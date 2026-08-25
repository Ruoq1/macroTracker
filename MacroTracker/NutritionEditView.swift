import SwiftUI

struct NutritionEditView: View {
    let title: String
    let unit: String
    @Binding var consumed: Double

    @Environment(\.dismiss) private var dismiss
    @State private var amount: Double = 0
    @State private var inputMethod: InputMethod = .ruler
    @FocusState private var isFocused: Bool

    private let range: ClosedRange<Double> = 0...300

    private enum InputMethod: String, CaseIterable {
        case ruler = "Ruler"
        case wheel = "Wheel"
        case manual = "Type"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("+\(formatted(amount))\(unit.isEmpty ? "" : " " + unit)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: amount)

                Picker("Input Method", selection: $inputMethod) {
                    ForEach(InputMethod.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                inputView
                    .frame(height: 190)

                Button(action: apply) {
                    Text("Add")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .disabled(amount <= 0)
                .opacity(amount <= 0 ? 0.5 : 1)

                Spacer()
            }
            .padding()
            .padding(.top, 16)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(560)])
    }

    @ViewBuilder
    private var inputView: some View {
        switch inputMethod {
        case .ruler:
            RulerPicker(value: $amount, range: range)
        case .wheel:
            Picker("Amount", selection: Binding(
                get: { Int(amount) },
                set: { amount = Double($0) }
            )) {
                ForEach(Int(range.lowerBound)...Int(range.upperBound), id: \.self) { n in
                    Text("\(n)\(unit.isEmpty ? "" : " " + unit)").tag(n)
                }
            }
            .pickerStyle(.wheel)
            .sensoryFeedback(.selection, trigger: Int(amount))
        case .manual:
            TextField("Amount", value: $amount, format: .number)
                .keyboardType(.decimalPad)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .onAppear { isFocused = true }
        }
    }

    private func apply() {
        guard amount > 0 else { return }
        consumed = max(0, consumed + amount)
        dismiss()
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview {
    NutritionEditView(title: "Protein", unit: "g", consumed: .constant(126))
}
