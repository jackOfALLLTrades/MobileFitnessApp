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

        session.sourceRoutine = routine
        session.startingExerciseNames = orderedExercises.map { $0.exercise.name }

        for (exerciseIndex, routineExercise) in orderedExercises.enumerated() {

            let workoutExercise = WorkoutExercise(
                exerciseName: routineExercise.exercise.name,
                order: exerciseIndex,
                loggingMode: routineExercise.exercise.loggingMode
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

    func routineToUpdate(for session: WorkoutSession, catalog: [Exercise]) -> Routine? {
        routineUpdate(for: session, catalog: catalog)?.routine
    }

    func finishSession(_ session: WorkoutSession, updateRoutine: Bool = false) throws {
        if updateRoutine {
            let catalog = try modelContext.fetch(FetchDescriptor<Exercise>())
            if let update = routineUpdate(for: session, catalog: catalog) {
                applyRoutineUpdate(update)
            }
        }

        session.endDate = Date()
        session.isCompleted = true
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private struct RoutineUpdate {
        let routine: Routine
        let exercises: [(exercise: Exercise, setCount: Int)]
    }

    private func routineUpdate(for session: WorkoutSession, catalog: [Exercise]) -> RoutineUpdate? {
        guard let routine = session.sourceRoutine,
              !routine.isDeleted,
              let startingNames = session.startingExerciseNames,
              !session.exercises.isEmpty else { return nil }

        let orderedExercises = session.exercises.sorted { $0.order < $1.order }
        let finalNames = orderedExercises.map(\.exerciseName)
        guard lineup(finalNames) != lineup(startingNames),
              lineup(finalNames) != lineup(routine.exercises.map { $0.exercise.name }) else {
            return nil
        }

        var exercises: [(exercise: Exercise, setCount: Int)] = []
        for workoutExercise in orderedExercises {
            guard let exercise = catalog.first(where: {
                $0.name.caseInsensitiveCompare(workoutExercise.exerciseName) == .orderedSame
            }) else { return nil }

            exercises.append((exercise, max(1, workoutExercise.sets.count)))
        }

        return RoutineUpdate(routine: routine, exercises: exercises)
    }

    // Sorting preserves counts of duplicate names while ignoring exercise order.
    private func lineup(_ names: [String]) -> [String] {
        names.map { $0.lowercased() }.sorted()
    }

    private func applyRoutineUpdate(_ update: RoutineUpdate) {
        var unmatched = update.routine.exercises

        for (index, entry) in update.exercises.enumerated() {
            if let matchIndex = unmatched.firstIndex(where: {
                $0.exercise.persistentModelID == entry.exercise.persistentModelID
            }) {
                unmatched.remove(at: matchIndex).order = index
            } else {
                let link = RoutineExercise(
                    exercise: entry.exercise,
                    order: index,
                    plannedSets: entry.setCount
                )
                link.routine = update.routine
                modelContext.insert(link)
            }
        }

        for link in unmatched {
            modelContext.delete(link)
        }
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
