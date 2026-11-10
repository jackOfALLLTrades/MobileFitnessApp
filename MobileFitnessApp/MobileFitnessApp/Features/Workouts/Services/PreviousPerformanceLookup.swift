//
//  PreviousPerformanceLookup.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation

/// Resolves previous set values from the latest matching completed workout.
struct PreviousPerformanceLookup {
    func previousPerformance(
        for exercise: WorkoutExercise,
        setOrder: Int,
        before session: WorkoutSession,
        in workoutSessions: [WorkoutSession],
        weightUnit: WorkoutWeightUnit = .pounds
    ) -> String {

        guard let previousExercise = latestExercise(for: exercise, before: session, in: workoutSessions),
              let previousSet = previousExercise.sets.sorted(by: { $0.order < $1.order })
                .first(where: { $0.order == setOrder }) else {
            return "—"
        }

        if !exercise.loggingMode.showsWeight {
            guard let count = previousSet.reps else { return "—" }
            return exercise.loggingMode == .timed ? "\(count) sec" : "\(count) reps"
        }

        let weight = previousSet.weight.map {
            WorkoutWeightFormatter.string(from: $0, unit: weightUnit)
        } ?? "—"

        let reps = previousSet.reps.map {
            String($0)
        } ?? "—"

        if previousSet.weight == nil && previousSet.reps == nil {
            return "—"
        }

        return "\(weight) × \(reps)"
    }

    func previousNotes(
        for exercise: WorkoutExercise,
        before session: WorkoutSession,
        in workoutSessions: [WorkoutSession]
    ) -> String? {
        let earlierSessions = workoutSessions
            .filter { $0.isCompleted && $0.startDate < session.startDate }
            .sorted { $0.startDate > $1.startDate }

        for earlierSession in earlierSessions {
            for match in earlierSession.exercises where
                match.exerciseName.caseInsensitiveCompare(exercise.exerciseName) == .orderedSame {
                if let note = match.visibleNotes.last(where: {
                    !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }) {
                    return note.text
                }
            }
        }
        return nil
    }

    private func latestExercise(
        for exercise: WorkoutExercise,
        before session: WorkoutSession,
        in workoutSessions: [WorkoutSession]
    ) -> WorkoutExercise? {
        let previousSessions = workoutSessions
            .filter { $0.isCompleted && $0.startDate < session.startDate }
            .sorted { $0.startDate > $1.startDate }

        for previousSession in previousSessions {
            if let match = previousSession.exercises.first(where: {
                $0.exerciseName.caseInsensitiveCompare(exercise.exerciseName) == .orderedSame
            }) {
                return match
            }
        }

        return nil
    }
}
