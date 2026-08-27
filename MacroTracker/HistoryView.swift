import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var records: [DayRecord] = HistoryStore.load()

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "No History Yet",
                        systemImage: "calendar",
                        description: Text("Past days will show up here once a new day begins.")
                    )
                } else {
                    List(records) { record in
                        recordRow(record)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func recordRow(_ record: DayRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(formatted(record.calories)) / \(formatted(record.calorieGoal)) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 14) {
                macroLabel("P", record.protein, record.proteinGoal)
                macroLabel("C", record.carbs, record.carbGoal)
                macroLabel("F", record.fat, record.fatGoal)
            }
        }
        .padding(.vertical, 4)
    }

    private func macroLabel(_ abbreviation: String, _ value: Double, _ goal: Double) -> some View {
        Text("\(abbreviation) \(formatted(value))/\(formatted(goal))g")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
    }
}

#Preview {
    HistoryView()
}
