import Foundation
import SwiftData

/// Performs edits to the active workout. Presentation and navigation stay in the view.
@MainActor
final class ActiveWorkoutViewModel {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addExercises(_ selectedExercises: [Exercise], to session: WorkoutSession) {
        let existingNames = Set(
            session.exercises.map {
                $0.exerciseName.lowercased()
            }
        )

        let newExercises = selectedExercises.filter {
            !existingNames.contains($0.name.lowercased())
        }

        guard !newExercises.isEmpty else {
            return
        }

        var nextOrder = (session.exercises.map(\.order).max() ?? -1) + 1

        for exercise in newExercises {
            let sessionExercise = SessionExercise(
                exerciseName: exercise.name,
                order: nextOrder
            )

            sessionExercise.session = session
            modelContext.insert(sessionExercise)

            let firstSet = WorkoutSet(order: 0)
            firstSet.sessionExercise = sessionExercise
            modelContext.insert(firstSet)

            nextOrder += 1
        }

        saveChanges()
    }

    func saveExerciseOrder(_ exercisesToReorder: [SessionExercise]) {
        for (index, exercise) in exercisesToReorder.enumerated() {
            exercise.order = index
        }

        saveChanges()
    }

    func deleteExercise(_ exercise: SessionExercise, from session: WorkoutSession) {
        let remainingExercises = session.exercises.sorted { $0.order < $1.order }.filter {
            $0.persistentModelID != exercise.persistentModelID
        }

        modelContext.delete(exercise)

        for (index, remainingExercise) in remainingExercises.enumerated() {
            remainingExercise.order = index
        }

        saveChanges()
    }

    func addSet(to exercise: SessionExercise) {
        let nextOrder = (exercise.sets.map(\.order).max() ?? -1) + 1

        let workoutSet = WorkoutSet(order: nextOrder)
        workoutSet.sessionExercise = exercise
        modelContext.insert(workoutSet)

        saveChanges()
    }

    func removeSet(
        _ workoutSet: WorkoutSet,
        from exercise: SessionExercise
    ) {
        let remainingSets = exercise.sets
            .filter {
                $0.persistentModelID != workoutSet.persistentModelID
            }
            .sorted {
                $0.order < $1.order
            }

        guard !remainingSets.isEmpty else {
            return
        }

        modelContext.delete(workoutSet)

        for (index, set) in remainingSets.enumerated() {
            set.order = index
        }

        saveChanges()
    }

    func toggleCompleted(_ workoutSet: WorkoutSet) {
        workoutSet.isCompleted.toggle()
        saveChanges()
    }

    func replaceExercise(_ exercise: SessionExercise, with replacement: Exercise) {
        exercise.exerciseName = replacement.name
        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save workout: \(error)")
        }
    }
}
