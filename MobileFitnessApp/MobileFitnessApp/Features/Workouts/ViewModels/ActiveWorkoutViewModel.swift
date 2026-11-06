import SwiftUI
import Observation
import SwiftData

/// Performs edits to the active workout. Presentation and navigation stay in the view.
@MainActor
@Observable
final class ActiveWorkoutViewModel {
    private var weightDrafts: [PersistentIdentifier: String] = [:]
    private var repsDrafts: [PersistentIdentifier: String] = [:]

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
            let workoutExercise = WorkoutExercise(
                exerciseName: exercise.name,
                order: nextOrder
            )

            workoutExercise.session = session
            modelContext.insert(workoutExercise)

            let firstSet = WorkoutSet(order: 0)
            firstSet.workoutExercise = workoutExercise
            modelContext.insert(firstSet)

            nextOrder += 1
        }

        saveChanges()
    }

    func saveExerciseOrder(_ exercisesToReorder: [WorkoutExercise]) {
        for (index, exercise) in exercisesToReorder.enumerated() {
            exercise.order = index
        }

        saveChanges()
    }

    func deleteExercise(_ exercise: WorkoutExercise, from session: WorkoutSession) {
        let remainingExercises = session.exercises.sorted { $0.order < $1.order }.filter {
            $0.persistentModelID != exercise.persistentModelID
        }

        for workoutSet in exercise.sets {
            clearDrafts(for: workoutSet)
        }
        modelContext.delete(exercise)

        for (index, remainingExercise) in remainingExercises.enumerated() {
            remainingExercise.order = index
        }

        saveChanges()
    }

    func addSet(to exercise: WorkoutExercise) {
        let nextOrder = (exercise.sets.map(\.order).max() ?? -1) + 1

        let workoutSet = WorkoutSet(order: nextOrder)
        workoutSet.workoutExercise = exercise
        modelContext.insert(workoutSet)

        saveChanges()
    }

    func removeSet(
        _ workoutSet: WorkoutSet,
        from exercise: WorkoutExercise
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

        clearDrafts(for: workoutSet)
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

    func replaceExercise(_ exercise: WorkoutExercise, with replacement: Exercise) {
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

    func weightBinding(
        for workoutSet: WorkoutSet
    ) -> Binding<String> {

        let id = workoutSet.persistentModelID

        return Binding(
            get: {
                self.weightDrafts[id] ??
                workoutSet.weight.map { String($0) } ?? ""
            },
            set: { newValue in
                self.weightDrafts[id] = newValue

                let normalizedValue = newValue.replacingOccurrences(
                    of: ",",
                    with: "."
                )

                if normalizedValue.isEmpty {
                    workoutSet.weight = nil
                } else if let value = Double(normalizedValue) {
                    workoutSet.weight = value
                }

                self.saveChanges()
            }
        )
    }

    func repsBinding(
        for workoutSet: WorkoutSet
    ) -> Binding<String> {

        let id = workoutSet.persistentModelID

        return Binding(
            get: {
                self.repsDrafts[id] ??
                workoutSet.reps.map { String($0) } ?? ""
            },
            set: { newValue in
                self.repsDrafts[id] = newValue
                workoutSet.reps = Int(newValue)
                self.saveChanges()
            }
        )
    }

    private func clearDrafts(for workoutSet: WorkoutSet) {
        weightDrafts.removeValue(forKey: workoutSet.persistentModelID)
        repsDrafts.removeValue(forKey: workoutSet.persistentModelID)
    }

    func finishWorkout(_ session: WorkoutSession) throws {
        session.endDate = Date()
        session.isCompleted = true
        try modelContext.save()
    }

    func discardWorkout(_ session: WorkoutSession) throws {
        modelContext.delete(session)
        try modelContext.save()
    }

    func selectedExercises(
        in session: WorkoutSession,
        from availableExercises: [Exercise]
    ) -> [Exercise] {
        let existingNames = Set(session.exercises.map { $0.exerciseName.lowercased() })
        return availableExercises.filter { existingNames.contains($0.name.lowercased()) }
    }
}
