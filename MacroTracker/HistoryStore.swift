import Foundation

struct DayRecord: Codable, Identifiable, Equatable {
    let date: Date
    let protein: Double
    let carbs: Double
    let fat: Double
    let proteinGoal: Double
    let carbGoal: Double
    let fatGoal: Double
    let calorieGoal: Double

    var id: Date { date }
    var calories: Double { protein * 4 + carbs * 4 + fat * 9 }
}

enum HistoryStore {
    private static let key = "trackingHistory"

    static func load() -> [DayRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([DayRecord].self, from: data)
        else { return [] }
        return records
    }

    /// Upserts a record for the given day, replacing any existing entry for that same day.
    static func append(_ record: DayRecord) {
        var records = load()
        records.removeAll { Calendar.current.isDate($0.date, inSameDayAs: record.date) }
        records.append(record)
        records.sort { $0.date > $1.date }
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
