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
        in workoutSessions: [WorkoutSession]
    ) -> String {

        let previousSessions = workoutSessions
            .filter {
                $0.isCompleted &&
                $0.startDate < session.startDate
            }
            .sorted {
                $0.startDate > $1.startDate
            }

        for previousSession in previousSessions {
            guard let previousExercise = previousSession.exercises.first(
                where: {
                    $0.exerciseName.caseInsensitiveCompare(
                        exercise.exerciseName
                    ) == .orderedSame
                }
            ) else {
                continue
            }

            let previousSets = previousExercise.sets.sorted {
                $0.order < $1.order
            }

            // Use the latest matching workout only; missing sets do not fall back to older sessions.
            guard let previousSet = previousSets.first(
                where: { $0.order == setOrder }
            ) else {
                return "—"
            }

            let weight = previousSet.weight.map {
                WorkoutWeightFormatter.string(from: $0)
            } ?? "—"

            let reps = previousSet.reps.map {
                String($0)
            } ?? "—"

            if previousSet.weight == nil && previousSet.reps == nil {
                return "—"
            }

            return "\(weight) × \(reps)"
        }

        return "—"
    }
}
