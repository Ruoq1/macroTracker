import SwiftUI

struct GoalSettingsView: View {
    @Binding var tdee: Double
    @Binding var calorieTargetPercent: Double
    @Binding var proteinGoal: Double
    @Binding var carbGoal: Double
    @Binding var fatGoal: Double

    private var calorieGoal: Double {
        tdee * calorieTargetPercent / 100
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
                goalRow(label: "Protein", value: $proteinGoal, unit: "g")
                goalRow(label: "Carbs", value: $carbGoal, unit: "g")
                goalRow(label: "Fat", value: $fatGoal, unit: "g")
            }
        }
        .navigationTitle("Daily Goals")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func goalRow(label: String, value: Binding<Double>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            if !unit.isEmpty {
                Text(unit).foregroundStyle(.secondary)
            }
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
