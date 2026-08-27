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
    @AppStorage("rowInputStyle") private var rowInputStyle: RowInputStyle = .ruler
    @AppStorage("rulerHighlightColor") private var rulerHighlightColor: AlertColor = .red

    @State private var showingSettings = false
    @State private var editingMetric: EditingMetric?
    @State private var activeMetric: EditingMetric?
    @State private var pendingAmount: Double = 0

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
                        rulerHighlightColor: rulerHighlightColor.color,
                        onTap: { editingMetric = .protein },
                        quickAddValue: rowInputStyle == .ruler ? pendingBinding(for: .protein) : nil
                    )

                    NutritionRow(
                        title: "Carbs",
                        consumed: carbsConsumed,
                        goal: carbGoal,
                        unit: "g",
                        sizeScale: 1.5,
                        lowThreshold: 0.3,
                        lowColor: lowAlertColor.color,
                        rulerHighlightColor: rulerHighlightColor.color,
                        onTap: { editingMetric = .carbs },
                        quickAddValue: rowInputStyle == .ruler ? pendingBinding(for: .carbs) : nil
                    )

                    NutritionRow(
                        title: "Fat",
                        consumed: fatConsumed,
                        goal: fatGoal,
                        unit: "g",
                        sizeScale: 1.5,
                        rulerHighlightColor: rulerHighlightColor.color,
                        onTap: { editingMetric = .fat },
                        quickAddValue: rowInputStyle == .ruler ? pendingBinding(for: .fat) : nil
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 70)
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
            .overlay(alignment: .bottom) {
                if let activeMetric, pendingAmount > 0 {
                    confirmBar(for: activeMetric)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
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

    private func confirmBar(for metric: EditingMetric) -> some View {
        HStack {
            Text("+\(formattedAmount) g \(metric.title)")
                .font(.subheadline.weight(.medium))

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.3)) { activeMetric = nil }
                pendingAmount = 0
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
            }

            Button {
                commitPending(for: metric)
            } label: {
                Image(systemName: "checkmark")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor, in: Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private var formattedAmount: String {
        pendingAmount.rounded() == pendingAmount ? String(Int(pendingAmount)) : String(format: "%.1f", pendingAmount)
    }

    private func pendingBinding(for metric: EditingMetric) -> Binding<Double> {
        Binding(
            get: { activeMetric == metric ? pendingAmount : 0 },
            set: { newValue in
                if activeMetric != metric {
                    withAnimation(.spring(duration: 0.3)) { activeMetric = metric }
                }
                pendingAmount = newValue
            }
        )
    }

    private func commitPending(for metric: EditingMetric) {
        let amount = pendingAmount
        let target = binding(for: metric)
        target.wrappedValue = max(0, target.wrappedValue + amount)
        withAnimation(.spring(duration: 0.3)) { activeMetric = nil }
        pendingAmount = 0
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
