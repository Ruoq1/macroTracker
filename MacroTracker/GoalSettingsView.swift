import SwiftUI

struct GoalSettingsView: View {
    @Binding var tdee: Double
    @Binding var calorieTargetPercent: Double
    @Binding var proteinGoal: Double
    @Binding var carbGoal: Double
    @Binding var fatGoal: Double

    @State private var editingMacro: MacroGoal?

    private var calorieGoal: Double {
        tdee * calorieTargetPercent / 100
    }

    private enum MacroGoal: String, Identifiable {
        case protein, carbs, fat
        var id: String { rawValue }

        var title: String {
            switch self {
            case .protein: "Protein Goal"
            case .carbs: "Carb Goal"
            case .fat: "Fat Goal"
            }
        }

        var color: Color {
            switch self {
            case .protein: .blue
            case .carbs: .orange
            case .fat: .purple
            }
        }
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Maintenance (TDEE)")
                    Spacer()
                    TextField("", value: $tdee, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Target")
                    Spacer()
                    TextField("", value: $calorieTargetPercent, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Text("%").foregroundStyle(.secondary)
                }
            } header: {
                Text("Calories")
            } footer: {
                Text("Goal: \(formatted(calorieGoal)) calories (\(formatted(calorieTargetPercent))% of TDEE)")
            }

            Section("Daily Goals") {
                goalRow(.protein, label: "Protein", value: proteinGoal)
                goalRow(.carbs, label: "Carbs", value: carbGoal)
                goalRow(.fat, label: "Fat", value: fatGoal)
            }
        }
        .navigationTitle("Daily Goals")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingMacro) { macro in
            GoalStepperEditView(
                title: macro.title,
                description: "Set your daily \(macro.rawValue) target in grams.",
                unitLabel: "GRAMS/DAY",
                footer: "This updates your \(macro.rawValue) goal used across the app.",
                confirmLabel: "Update \(macro.title)",
                value: binding(for: macro),
                step: 5,
                range: 0...400,
                accentColor: macro.color
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }

    @ViewBuilder
    private func goalRow(_ macro: MacroGoal, label: String, value: Double) -> some View {
        Button {
            editingMacro = macro
        } label: {
            HStack {
                Text(label)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(formatted(value)) g")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func binding(for macro: MacroGoal) -> Binding<Double> {
        switch macro {
        case .protein: $proteinGoal
        case .carbs: $carbGoal
        case .fat: $fatGoal
        }
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview {
    NavigationStack {
        GoalSettingsView(
            tdee: .constant(2000),
            calorieTargetPercent: .constant(80),
            proteinGoal: .constant(160),
            carbGoal: .constant(180),
            fatGoal: .constant(60)
        )
    }
}
