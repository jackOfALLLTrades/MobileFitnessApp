// xcode: set sdk=iOS

//
//  LogViewModel.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import Foundation
import Observation

@Observable
class LogViewModel {
    //Newest first
    var sessions: [Session] = []

    //logs a session
    func logSession(session: Session) {
        sessions.append(session)
        sessions.sort { $0.date > $1.date }
    }

    //logs a workout as a session right now
    func logSession(from workout: Workout) {
        logSession(session: Session(date: Date(), name: workout.name, workout: workout, exercises: workout.exercises))
    }

    func deleteSession(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            sessions.remove(at: index)
        }
    }

    // MARK: Tracking stats

    var sessionsThisWeek: Int {
        guard let week = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        return sessions.filter { week.contains($0.date) }.count
    }

    //Days in a row with at least one session (today doesn't have to be logged yet)
    var currentStreak: Int {
        let calendar = Calendar.current
        let days = sessions.map { calendar.startOfDay(for: $0.date) }
        var day = calendar.startOfDay(for: Date())
        if !days.contains(day) {
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        var streak = 0
        while days.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return streak
    }

    var totalVolume: Int {
        sessions.reduce(0) { $0 + $1.volume }
    }

    //Heaviest weight ever logged for an exercise (nil if never logged with weight)
    func bestWeight(for exerciseName: String) -> Int? {
        sessions
            .flatMap { $0.exercises ?? [] }
            .filter { $0.name == exerciseName }
            .flatMap { $0.sets }
            .compactMap { $0.weight }
            .max()
    }

    //How many sessions included this exercise
    func timesLogged(_ exerciseName: String) -> Int {
        sessions.filter { session in
            (session.exercises ?? []).contains { $0.name == exerciseName }
        }.count
    }
}
