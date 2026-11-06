//
//  WorkoutSessionService.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation
import SwiftData

/// Owns persistence for the beginning and end of a workout, independently of UI state.
@MainActor
struct WorkoutSessionService {
    let modelContext: ModelContext

    func createSession(from routine: Routine) throws -> WorkoutSession {
        let session = WorkoutSession(name: routine.name)

        modelContext.insert(session)

        let orderedExercises = routine.exercises.sorted {
            $0.order < $1.order
        }

        for (exerciseIndex, routineExercise) in orderedExercises.enumerated() {

            let workoutExercise = WorkoutExercise(
                exerciseName: routineExercise.exercise.name,
                order: exerciseIndex
            )

            workoutExercise.session = session
            modelContext.insert(workoutExercise)

            let plannedSetCount = max(1, routineExercise.plannedSets)

            for setIndex in 0..<plannedSetCount {

                let workoutSet = WorkoutSet(order: setIndex)
                workoutSet.workoutExercise = workoutExercise

                modelContext.insert(workoutSet)
            }
        }

        try modelContext.save()
        return session
    }

    func finishSession(_ session: WorkoutSession) throws {
        session.endDate = Date()
        session.isCompleted = true
        try modelContext.save()
    }

    func discardSession(_ session: WorkoutSession) throws {
        modelContext.delete(session)
        try modelContext.save()
    }

    func latestUnfinishedSession() throws -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted == false },
            sortBy: [SortDescriptor(\WorkoutSession.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
