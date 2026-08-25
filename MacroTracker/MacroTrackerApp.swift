import SwiftUI

@main
struct MacroTrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("lastTrackingDate") private var lastTrackingTimestamp: Double = 0
    @AppStorage("caloriesConsumed") private var caloriesConsumed = 0.0
    @AppStorage("proteinConsumed") private var proteinConsumed = 0.0
    @AppStorage("carbsConsumed") private var carbsConsumed = 0.0
    @AppStorage("fatConsumed") private var fatConsumed = 0.0

    var body: some Scene {
        WindowGroup {
            MainTrackerView()
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        resetIfNewDay()
                    }
                }
        }
    }

    private func resetIfNewDay() {
        let today = Date()
        let lastDate = Date(timeIntervalSince1970: lastTrackingTimestamp)

        if lastTrackingTimestamp == 0 || !Calendar.current.isDate(lastDate, inSameDayAs: today) {
            caloriesConsumed = 0
            proteinConsumed = 0
            carbsConsumed = 0
            fatConsumed = 0
        }

        lastTrackingTimestamp = today.timeIntervalSince1970
    }
}
