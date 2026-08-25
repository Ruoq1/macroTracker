import SwiftUI

enum AlertColor: String, CaseIterable, Identifiable {
    case red, purple, pink, yellow

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .red: .red
        case .purple: .purple
        case .pink: .pink
        case .yellow: .yellow
        }
    }

    var label: String {
        switch self {
        case .red: "Red"
        case .purple: "Purple"
        case .pink: "Pink"
        case .yellow: "Yellow"
        }
    }
}

struct SettingsView: View {
    @Binding var tdee: Double
    @Binding var calorieTargetPercent: Double
    @Binding var proteinGoal: Double
    @Binding var carbGoal: Double
    @Binding var fatGoal: Double

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Daily Goals") {
                    GoalSettingsView(
                        tdee: $tdee,
                        calorieTargetPercent: $calorieTargetPercent,
                        proteinGoal: $proteinGoal,
                        carbGoal: $carbGoal,
                        fatGoal: $fatGoal
                    )
                }
                NavigationLink("Alert Color") {
                    AlertColorSettingsView()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct AlertColorSettingsView: View {
    @AppStorage("lowAlertColor") private var lowAlertColor: AlertColor = .red

    var body: some View {
        List {
            Section {
                ForEach(AlertColor.allCases, id: \.self, content: colorRow)
            } footer: {
                Text("Used when Protein or Carbs intake is far below your goal.")
            }
        }
        .navigationTitle("Alert Color")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func colorRow(for option: AlertColor) -> some View {
        Button {
            lowAlertColor = option
        } label: {
            HStack {
                Circle()
                    .fill(option.color)
                    .frame(width: 18, height: 18)
                Text(option.label)
                    .foregroundStyle(.primary)
                Spacer()
                if option == lowAlertColor {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

#Preview {
    SettingsView(
        tdee: .constant(2000),
        calorieTargetPercent: .constant(80),
        proteinGoal: .constant(160),
        carbGoal: .constant(180),
        fatGoal: .constant(60)
    )
}
