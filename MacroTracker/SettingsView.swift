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

enum RowInputStyle: String, CaseIterable, Identifiable {
    case ruler, progressBar

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ruler: "Ruler"
        case .progressBar: "Progress Bar"
        }
    }

    var detail: String {
        switch self {
        case .ruler: "Drag to quick-add"
        case .progressBar: "Read-only, shows % of goal"
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
                    ColorPickerSettingsView(
                        storageKey: "lowAlertColor",
                        title: "Alert Color",
                        footer: "Used when Protein or Carbs intake is far below your goal."
                    )
                }
                NavigationLink("Ruler Color") {
                    ColorPickerSettingsView(
                        storageKey: "rulerHighlightColor",
                        title: "Ruler Color",
                        footer: "Highlights every 5th tick on the quick-add ruler."
                    )
                }
                NavigationLink("Input Style") {
                    RowInputStyleSettingsView()
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

private struct ColorPickerSettingsView: View {
    let title: String
    let footer: String
    @AppStorage private var selection: AlertColor

    init(storageKey: String, title: String, footer: String) {
        self.title = title
        self.footer = footer
        _selection = AppStorage(wrappedValue: .red, storageKey)
    }

    var body: some View {
        List {
            Section {
                ForEach(AlertColor.allCases, id: \.self, content: colorRow)
            } footer: {
                Text(footer)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func colorRow(for option: AlertColor) -> some View {
        Button {
            selection = option
        } label: {
            HStack {
                Circle()
                    .fill(option.color)
                    .frame(width: 18, height: 18)
                Text(option.label)
                    .foregroundStyle(.primary)
                Spacer()
                if option == selection {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

private struct RowInputStyleSettingsView: View {
    @AppStorage("rowInputStyle") private var rowInputStyle: RowInputStyle = .ruler

    var body: some View {
        List {
            Section {
                ForEach(RowInputStyle.allCases, id: \.self, content: styleRow)
            } footer: {
                Text("Controls how Protein, Carbs, and Fat are adjusted from the main screen.")
            }
        }
        .navigationTitle("Input Style")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func styleRow(for option: RowInputStyle) -> some View {
        Button {
            rowInputStyle = option
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .foregroundStyle(.primary)
                    Text(option.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if option == rowInputStyle {
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
