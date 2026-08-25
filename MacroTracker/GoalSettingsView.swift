import SwiftUI

struct GoalSettingsView: View {
    @Binding var calorieGoal: Double
    @Binding var proteinGoal: Double
    @Binding var carbGoal: Double
    @Binding var fatGoal: Double

    var body: some View {
        Form {
            Section("Daily Goals") {
                goalRow(label: "Calories", value: $calorieGoal, unit: "")
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
}

#Preview {
    NavigationStack {
        GoalSettingsView(
            calorieGoal: .constant(2000),
            proteinGoal: .constant(160),
            carbGoal: .constant(180),
            fatGoal: .constant(60)
        )
    }
}
