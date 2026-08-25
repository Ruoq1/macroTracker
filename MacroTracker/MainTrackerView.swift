import SwiftUI

struct MainTrackerView: View {
    @AppStorage("tdee") private var tdee = 2000.0
    @AppStorage("calorieTargetPercent") private var calorieTargetPercent = 100.0
    @AppStorage("proteinConsumed") private var proteinConsumed = 0.0
    @AppStorage("proteinGoal") private var proteinGoal = 160.0
    @AppStorage("carbsConsumed") private var carbsConsumed = 0.0
    @AppStorage("carbGoal") private var carbGoal = 180.0
    @AppStorage("fatConsumed") private var fatConsumed = 0.0
    @AppStorage("fatGoal") private var fatGoal = 60.0
    @AppStorage("lowAlertColor") private var lowAlertColor: AlertColor = .red

    @State private var showingSettings = false
    @State private var editingMetric: EditingMetric?

    private var caloriesConsumed: Double {
        proteinConsumed * 4 + carbsConsumed * 4 + fatConsumed * 9
    }

    private var calorieGoal: Double {
        tdee * calorieTargetPercent / 100
    }

    /// Cutting (< 100% target): warn once intake creeps past maintenance.
    /// Bulking (>= 100% target): warn if intake falls short of the surplus goal.
    private var calorieIsOver: Bool {
        calorieTargetPercent < 100 ? caloriesConsumed > tdee : caloriesConsumed < calorieGoal
    }

    private var todayString: String {
        Date.now.formatted(date: .abbreviated, time: .omitted)
    }

    private var tdeeLabel: String {
        let value = tdee.rounded() == tdee ? String(Int(tdee)) : String(format: "%.1f", tdee)
        return "TDEE \(value)"
    }

    private enum EditingMetric: String, Identifiable {
        case protein, carbs, fat
        var id: String { rawValue }

        var title: String {
            switch self {
            case .protein: "Protein"
            case .carbs: "Carbs"
            case .fat: "Fat"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    NutritionRow(
                        title: "Calories",
                        consumed: caloriesConsumed,
                        goal: calorieGoal,
                        unit: "",
                        sizeScale: 1.0,
                        statusReference: tdee,
                        overLabel: "surplus",
                        underLabel: "deficit",
                        isOverOverride: calorieIsOver,
                        subtitle: tdeeLabel
                    )

                    NutritionRow(
                        title: "Protein",
                        consumed: proteinConsumed,
                        goal: proteinGoal,
                        unit: "g",
                        sizeScale: 1.5,
                        lowThreshold: 0.3,
                        lowColor: lowAlertColor.color,
                        onTap: { editingMetric = .protein },
                        onQuickAdd: { delta in proteinConsumed = max(0, proteinConsumed + delta) }
                    )

                    NutritionRow(
                        title: "Carbs",
                        consumed: carbsConsumed,
                        goal: carbGoal,
                        unit: "g",
                        sizeScale: 1.5,
                        lowThreshold: 0.3,
                        lowColor: lowAlertColor.color,
                        onTap: { editingMetric = .carbs },
                        onQuickAdd: { delta in carbsConsumed = max(0, carbsConsumed + delta) }
                    )

                    NutritionRow(
                        title: "Fat",
                        consumed: fatConsumed,
                        goal: fatGoal,
                        unit: "g",
                        sizeScale: 1.5,
                        onTap: { editingMetric = .fat },
                        onQuickAdd: { delta in fatConsumed = max(0, fatConsumed + delta) }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
            }
            .navigationTitle(todayString)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(
                    tdee: $tdee,
                    calorieTargetPercent: $calorieTargetPercent,
                    proteinGoal: $proteinGoal,
                    carbGoal: $carbGoal,
                    fatGoal: $fatGoal
                )
            }
            .sheet(item: $editingMetric) { metric in
                NutritionEditView(
                    title: metric.title,
                    unit: "g",
                    consumed: binding(for: metric)
                )
            }
        }
    }

    private func binding(for metric: EditingMetric) -> Binding<Double> {
        switch metric {
        case .protein: $proteinConsumed
        case .carbs: $carbsConsumed
        case .fat: $fatConsumed
        }
    }
}

#Preview {
    MainTrackerView()
}
