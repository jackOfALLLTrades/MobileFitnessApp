//
//  DeveloperHistorySection.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/9/26.
//

#if DEBUG
import SwiftUI
import SwiftData

struct DeveloperHistorySection: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.calendar) private var calendar
    @State private var confirmingClear = false
    @State private var result: String?

    var body: some View {
        Section("Developer Tools") {
            Button("Populate Demo History") {
                run {
                    let count = try history.populate(calendar: calendar)
                    return count == 0
                        ? "No demo workouts were available for this date range."
                        : "Populated \(count) completed demo workouts."
                }
            }
            .themeListRow()

            Button("Clear Workout History", role: .destructive) {
                confirmingClear = true
            }
            .themeListRow()
        }
        .confirmationDialog(
            "Clear Workout History?",
            isPresented: $confirmingClear,
            titleVisibility: .visible
        ) {
            Button("Clear All Completed Workouts", role: .destructive) {
                run {
                    let count = try history.clear()
                    return "Removed \(count) completed workouts."
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes all completed workouts, including real and demo sets and notes. Routines and any active workout are kept.")
        }
        .alert("Developer Tools", isPresented: Binding(
            get: { result != nil },
            set: { if !$0 { result = nil } }
        )) {
            Button("OK") { result = nil }
        } message: {
            Text(result ?? "")
        }
    }

    private var history: DeveloperWorkoutHistory {
        DeveloperWorkoutHistory(modelContext: modelContext)
    }

    private func run(_ action: () throws -> String) {
        do {
            result = try action()
        } catch {
            result = "Couldn’t update workout history. \(error.localizedDescription)"
        }
    }
}

@MainActor
private struct DeveloperWorkoutHistory {
    let modelContext: ModelContext

    private static let templates: [(name: String, exercises: [(name: String, weight: Double?, reps: Int)])] = [
        ("Demo · Push Day", [("Bench Press", 135, 8), ("Dumbbell Shoulder Press", 35, 10), ("Push-Up", nil, 12)]),
        ("Demo · Pull Day", [("Barbell Row", 95, 10), ("Pull-Up", nil, 6), ("Cable Face Pull", 30, 12)]),
        ("Demo · Leg Day", [("Squat", 155, 8), ("Romanian Deadlift", 115, 10), ("Plank", nil, 30)]),
        ("Demo · Upper Day", [("Incline Dumbbell Bench Press", 45, 10), ("Seated Cable Row", 85, 12), ("Lateral Raise", 15, 15)]),
        ("Demo · Lower Day", [("Leg Press", 180, 10), ("Leg Curl", 65, 12), ("Hanging Leg Raise", nil, 10)])
    ]

    func populate(calendar preferredCalendar: Calendar, now: Date = .now) throws -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = preferredCalendar.timeZone
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        guard let august = calendar.date(from: DateComponents(
            year: month >= 8 ? year : year - 1, month: 8, day: 1, hour: 12
        )) else { return 0 }

        let daysUntilMonday = (9 - calendar.component(.weekday, from: august)) % 7
        guard let firstMonday = calendar.date(byAdding: .day, value: daysUntilMonday, to: august) else {
            return 0
        }

        // Match the original and current demo templates so real workouts remain in history.
        let previousDemos = try completedWorkouts().filter { session in
            guard let template = Self.templates.first(where: { $0.name == session.name }) else {
                return false
            }
            return session.exercises.sorted { $0.order < $1.order }.map(\.exerciseName)
                == template.exercises.map { $0.name }
        }
        for session in previousDemos {
            modelContext.delete(session)
        }

        var added = 0
        for week in 0...52 {
            let days = trainingDays(in: week)
            for (index, day) in days.enumerated() {
                guard let day else { continue }
                let offset = week * 7 + day
                guard let start = calendar.date(byAdding: .day, value: offset, to: firstMonday) else { continue }
                let end = start.addingTimeInterval(Double(40 + (offset % 5) * 5) * 60)
                guard end <= now else { continue }

                let template = Self.templates[index]
                let session = WorkoutSession(name: template.name, startDate: start)
                session.endDate = end
                session.isCompleted = true
                modelContext.insert(session)

                for (index, entry) in template.exercises.enumerated() {
                    let exercise = WorkoutExercise(
                        exerciseName: entry.name,
                        order: index,
                        loggingMode: ExerciseCatalog.loggingMode(for: entry.name)
                    )
                    exercise.session = session
                    modelContext.insert(exercise)

                    for setIndex in 0..<3 {
                        let set = WorkoutSet(
                            weight: entry.weight.map { $0 + Double(offset / 14) * 5 },
                            reps: entry.reps,
                            order: setIndex
                        )
                        set.isCompleted = true
                        set.workoutExercise = exercise
                        modelContext.insert(set)
                    }
                }
                added += 1
            }
        }

        if added > 0 || !previousDemos.isEmpty { try save() }
        return added
    }

    private func trainingDays(in week: Int) -> [Int?] {
        switch week % 7 {
        case 2: [0, 1, 3, 4, 6]
        case 4: [0, 2, 3, 5, nil]
        case 6: [1, 2, 3, nil, 6]
        default: [0, 1, 2, 4, 5]
        }
    }

    func clear() throws -> Int {
        let workouts = try completedWorkouts()
        for workout in workouts {
            modelContext.delete(workout)
        }
        if !workouts.isEmpty { try save() }
        return workouts.count
    }

    private func completedWorkouts() throws -> [WorkoutSession] {
        try modelContext.fetch(FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted }
        ))
    }

    private func save() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
#endif
