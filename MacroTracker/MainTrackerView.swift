import SwiftUI

struct MainTrackerView: View {
    @AppStorage("calorieGoal") private var calorieGoal = 2000.0
    @AppStorage("proteinConsumed") private var proteinConsumed = 0.0
    @AppStorage("proteinGoal") private var proteinGoal = 160.0
    @AppStorage("carbsConsumed") private var carbsConsumed = 0.0
    @AppStorage("carbGoal") private var carbGoal = 180.0
    @AppStorage("fatConsumed") private var fatConsumed = 0.0
    @AppStorage("fatGoal") private var fatGoal = 60.0

    @State private var showingSettings = false
    @State private var editingMetric: EditingMetric?

    private var caloriesConsumed: Double {
        proteinConsumed * 4 + carbsConsumed * 4 + fatConsumed * 9
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
                VStack(spacing: 26) {
                    NutritionRow(
                        title: "Calories",
                        consumed: caloriesConsumed,
                        goal: calorieGoal,
                        unit: "",
                        sizeScale: 1.0
                    )

                    NutritionRow(
                        title: "Protein",
                        consumed: proteinConsumed,
                        goal: proteinGoal,
                        unit: "g",
                        sizeScale: 1.5
                    ) { editingMetric = .protein }

                    NutritionRow(
                        title: "Carbs",
                        consumed: carbsConsumed,
                        goal: carbGoal,
                        unit: "g",
                        sizeScale: 1.5
                    ) { editingMetric = .carbs }

                    NutritionRow(
                        title: "Fat",
                        consumed: fatConsumed,
                        goal: fatGoal,
                        unit: "g",
                        sizeScale: 1.5
                    ) { editingMetric = .fat }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Goals")
                }
            }
            .sheet(isPresented: $showingSettings) {
                GoalSettingsView(
                    calorieGoal: $calorieGoal,
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
