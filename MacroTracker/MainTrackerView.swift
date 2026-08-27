import SwiftUI

struct MainTrackerView: View {
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("lastTrackingDate") private var lastTrackingTimestamp: Double = 0
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
    @State private var pendingAmounts: [EditingMetric: Double] = [:]
    @State private var confirmBarDragOffset: CGFloat = 0
    @State private var isDismissingConfirmBar = false
    @State private var now = Date.now
    @State private var midnightTimer: Timer?

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
        now.formatted(date: .abbreviated, time: .omitted)
    }

    private var tdeeLabel: String {
        let value = tdee.rounded() == tdee ? String(Int(tdee)) : String(format: "%.1f", tdee)
        return "TDEE \(value)"
    }

    private var hasPending: Bool {
        pendingAmounts.values.contains { $0 != 0 }
    }

    private enum EditingMetric: String, Identifiable, CaseIterable {
        case protein, carbs, fat
        var id: String { rawValue }

        var title: String {
            switch self {
            case .protein: "Protein"
            case .carbs: "Carbs"
            case .fat: "Fat"
            }
        }

        var abbreviation: String {
            switch self {
            case .protein: "P"
            case .carbs: "C"
            case .fat: "F"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
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
                .padding(.top, 8)
                .padding(.bottom, hasPending ? 110 : 24)
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
                if hasPending {
                    confirmBar
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
        .onAppear {
            resetIfNewDay()
            scheduleMidnightTimer()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                resetIfNewDay()
                scheduleMidnightTimer()
            }
        }
        .onDisappear {
            midnightTimer?.invalidate()
        }
    }

    /// Resets the three tracked macros when the last recorded day differs from
    /// today. Cheap (a few UserDefaults reads/writes), so it's safe to call
    /// eagerly on launch and on every foreground/timer tick without any
    /// visible delay.
    private func resetIfNewDay() {
        let today = Date()
        let lastDate = Date(timeIntervalSince1970: lastTrackingTimestamp)

        if lastTrackingTimestamp == 0 || !Calendar.current.isDate(lastDate, inSameDayAs: today) {
            proteinConsumed = 0
            carbsConsumed = 0
            fatConsumed = 0
        }

        lastTrackingTimestamp = today.timeIntervalSince1970
        now = today
    }

    /// Fires once at the next local midnight so the date/reset update live
    /// while the app stays open, without requiring a background/foreground
    /// cycle. iOS suspends timers while backgrounded, so `resetIfNewDay()` on
    /// scenePhase changes remains the fallback for that case.
    private func scheduleMidnightTimer() {
        midnightTimer?.invalidate()

        guard let nextMidnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else { return }

        midnightTimer = Timer.scheduledTimer(withTimeInterval: nextMidnight.timeIntervalSinceNow, repeats: false) { _ in
            DispatchQueue.main.async {
                resetIfNewDay()
                scheduleMidnightTimer()
            }
        }
    }

    private var confirmBar: some View {
        Text(pendingSummary)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .lineLimit(2)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .background(Color.accentColor, in: Capsule())
            .contentShape(Capsule())
            .offset(x: confirmBarDragOffset)
            .opacity(isDismissingConfirmBar ? 0 : 1)
            .onTapGesture { commitAllPending() }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { gesture in
                        confirmBarDragOffset = min(0, gesture.translation.width)
                    }
                    .onEnded { gesture in
                        if gesture.translation.width < -80 {
                            withAnimation(.easeIn(duration: 0.22)) {
                                confirmBarDragOffset = -600
                                isDismissingConfirmBar = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                pendingAmounts.removeAll()
                                confirmBarDragOffset = 0
                                isDismissingConfirmBar = false
                            }
                        } else {
                            withAnimation(.spring(duration: 0.3)) {
                                confirmBarDragOffset = 0
                            }
                        }
                    }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
    }

    private var pendingSummary: String {
        EditingMetric.allCases
            .compactMap { metric -> String? in
                guard let amount = pendingAmounts[metric], amount != 0 else { return nil }
                let sign = amount > 0 ? "+" : ""
                return "\(metric.abbreviation) \(sign)\(formatted(amount))g"
            }
            .joined(separator: "  ·  ")
    }

    private func pendingBinding(for metric: EditingMetric) -> Binding<Double> {
        Binding(
            get: { pendingAmounts[metric] ?? 0 },
            set: { newValue in pendingAmounts[metric] = newValue }
        )
    }

    private func commitAllPending() {
        for metric in EditingMetric.allCases {
            guard let amount = pendingAmounts[metric], amount != 0 else { continue }
            let target = binding(for: metric)
            target.wrappedValue = max(0, target.wrappedValue + amount)
        }
        withAnimation(.spring(duration: 0.3)) { pendingAmounts.removeAll() }
    }

    private func binding(for metric: EditingMetric) -> Binding<Double> {
        switch metric {
        case .protein: $proteinConsumed
        case .carbs: $carbsConsumed
        case .fat: $fatConsumed
        }
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview {
    MainTrackerView()
}
