//
//  ActiveWorkoutView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var workoutSessionManager: WorkoutSessionManager

    @Query(sort: \WorkoutSession.startDate, order: .reverse)
    private var workoutSessions: [WorkoutSession]

    @Query(sort: \Exercise.name)
    private var availableExercises: [Exercise]

    let session: WorkoutSession

    @State private var showingFinishConfirmation = false
    @State private var showingDiscardConfirmation = false
    @State private var showingExerciseSelection = false
    @State private var showingReplacementSelection = false
    @State private var showingReorderExercises = false
    @State private var showingDeleteExerciseConfirmation = false
    @State private var showingReplacementUnavailable = false
    @State private var showingSettingsMessage = false

    @State private var selectedExercises: [Exercise] = []
    @State private var exercisesToReorder: [SessionExercise] = []

    @State private var exerciseBeingReplaced: SessionExercise?
    @State private var exerciseBeingDeleted: SessionExercise?
    @State private var replacementTargetID: PersistentIdentifier?

    @State private var weightDrafts: [PersistentIdentifier: String] = [:]
    @State private var repsDrafts: [PersistentIdentifier: String] = [:]

    private var workoutEditor: ActiveWorkoutViewModel {
        ActiveWorkoutViewModel(modelContext: modelContext)
    }

    private var orderedExercises: [SessionExercise] {
        session.exercises.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {

            // MARK: Workout Header

            WorkoutHeaderView(
                startDate: session.startDate,
                exerciseCount: orderedExercises.count
            )

            // MARK: Exercises

            ForEach(orderedExercises) { exercise in
                WorkoutExerciseSection(
                    exercise: exercise,
                    previousPerformance: { setOrder in
                        previousPerformance(
                            for: exercise,
                            setOrder: setOrder
                        )
                    },
                    weightBinding: { workoutSet in
                        weightBinding(for: workoutSet)
                    },
                    repsBinding: { workoutSet in
                        repsBinding(for: workoutSet)
                    },
                    onToggleCompleted: { workoutSet in
                        workoutEditor.toggleCompleted(workoutSet)
                    },
                    onRemoveSet: { workoutSet in
                        removeSet(workoutSet, from: exercise)
                    },
                    onAddSet: {
                        addSet(to: exercise)
                    },
                    onReorderExercises: {
                        prepareExerciseReordering()
                    },
                    onReplaceExercise: {
                        prepareExerciseReplacement(for: exercise)
                    },
                    onDeleteExercise: {
                        exerciseBeingDeleted = exercise
                        showingDeleteExerciseConfirmation = true
                    }
                )
            }

            // MARK: Workout Actions

            WorkoutActionsView(
                onAddExercise: {
                    prepareExerciseSelection()
                },
                onSettings: {
                    showingSettingsMessage = true
                },
                onDiscard: {
                    showingDiscardConfirmation = true
                }
            )
        }
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                minimizeButton
            }

            ToolbarItem(placement: .topBarTrailing) {
                finishButton
            }
        }

        // MARK: Exercise Selection

        .sheet(
            isPresented: $showingExerciseSelection,
            onDismiss: addSelectedExercises
        ) {
            NavigationStack {
                ExerciseSelectionView(
                    selectedExercises: $selectedExercises
                )
            }
        }

        // MARK: Exercise Reordering

        .sheet(
            isPresented: $showingReorderExercises,
            onDismiss: saveExerciseOrder
        ) {
            NavigationStack {
                ReorderExercisesView(
                    exercises: $exercisesToReorder,
                    exerciseName: { $0.exerciseName }
                )
            }
        }

        // MARK: Exercise Replacement

        .sheet(
            isPresented: $showingReplacementSelection,
            onDismiss: {
                selectedExercises = []
                exerciseBeingReplaced = nil
                replacementTargetID = nil
            }
        ) {
            NavigationStack {
                if let replacementTargetID {
                    ExerciseSelectionView(
                        selectedExercises: $selectedExercises,
                        replacementTargetID: replacementTargetID,
                        onReplace: { replacement in
                            if let exerciseBeingReplaced {
                                workoutEditor.replaceExercise(
                                    exerciseBeingReplaced,
                                    with: replacement
                                )
                            }
                        }
                    )
                }
            }
        }

        // MARK: Confirmation Dialogs

        .confirmationDialog(
            "Finish Workout?",
            isPresented: $showingFinishConfirmation,
            titleVisibility: .visible
        ) {
            Button("Finish Workout") {
                finishWorkout()
            }

            Button("Keep Working", role: .cancel) {}
        } message: {
            Text("Your workout will be saved to your history.")
        }

        .confirmationDialog(
            "Discard Workout?",
            isPresented: $showingDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard Workout", role: .destructive) {
                discardWorkout()
            }

            Button("Keep Working", role: .cancel) {}
        } message: {
            Text("This will permanently delete your current workout and all its logged sets.")
        }

        .confirmationDialog(
            "Delete Exercise?",
            isPresented: $showingDeleteExerciseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Exercise", role: .destructive) {
                if let exercise = exerciseBeingDeleted {
                    deleteExercise(exercise)
                }

                exerciseBeingDeleted = nil
            }

            Button("Cancel", role: .cancel) {
                exerciseBeingDeleted = nil
            }
        } message: {
            Text("This will remove the exercise and all of its sets from this workout.")
        }

        // MARK: Alerts

        .alert(
            "Exercise Unavailable",
            isPresented: $showingReplacementUnavailable
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This exercise could not be found in your exercise library, so it cannot be replaced.")
        }

        .alert(
            "Workout Settings",
            isPresented: $showingSettingsMessage
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Workout settings will be available in a future update.")
        }
    }

    // MARK: - Toolbar Buttons

    private var minimizeButton: some View {
        Button {
            workoutSessionManager.minimizeSession()
            dismiss()
        } label: {
            Image(systemName: "chevron.down")
                .font(.headline)
        }
        .accessibilityLabel("Minimize workout")
    }

    private var finishButton: some View {
        Button("Finish") {
            showingFinishConfirmation = true
        }
        .fontWeight(.semibold)
    }

    // MARK: - Previous Performance

    private func previousPerformance(
        for exercise: SessionExercise,
        setOrder: Int
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

            guard let previousSet = previousSets.first(
                where: { $0.order == setOrder }
            ) else {
                return "—"
            }

            let weight = previousSet.weight.map {
                formatNumber($0)
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

    private func formatNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(value)
    }

    // MARK: - Exercise Management

    private func prepareExerciseSelection() {
        let existingNames = Set(
            session.exercises.map {
                $0.exerciseName.lowercased()
            }
        )

        selectedExercises = availableExercises.filter {
            existingNames.contains($0.name.lowercased())
        }

        showingExerciseSelection = true
    }

    private func addSelectedExercises() {
        workoutEditor.addExercises(selectedExercises, to: session)
        selectedExercises = []
    }

    private func prepareExerciseReordering() {
        exercisesToReorder = orderedExercises
        showingReorderExercises = true
    }

    private func saveExerciseOrder() {
        workoutEditor.saveExerciseOrder(exercisesToReorder)
    }

    private func prepareExerciseReplacement(
        for exercise: SessionExercise
    ) {
        guard let targetExercise = availableExercises.first(
            where: {
                $0.name.caseInsensitiveCompare(
                    exercise.exerciseName
                ) == .orderedSame
            }
        ) else {
            showingReplacementUnavailable = true
            return
        }

        let existingNames = Set(
            session.exercises.map {
                $0.exerciseName.lowercased()
            }
        )

        selectedExercises = availableExercises.filter {
            existingNames.contains($0.name.lowercased())
        }

        exerciseBeingReplaced = exercise
        replacementTargetID = targetExercise.persistentModelID
        showingReplacementSelection = true
    }

    private func deleteExercise(_ exercise: SessionExercise) {
        for workoutSet in exercise.sets {
            clearDrafts(for: workoutSet)
        }
        workoutEditor.deleteExercise(exercise, from: session)
    }

    // MARK: - Text Field Bindings

    private func weightBinding(
        for workoutSet: WorkoutSet
    ) -> Binding<String> {

        let id = workoutSet.persistentModelID

        return Binding(
            get: {
                weightDrafts[id] ??
                workoutSet.weight.map { String($0) } ?? ""
            },
            set: { newValue in
                weightDrafts[id] = newValue

                let normalizedValue = newValue.replacingOccurrences(
                    of: ",",
                    with: "."
                )

                if normalizedValue.isEmpty {
                    workoutSet.weight = nil
                } else if let value = Double(normalizedValue) {
                    workoutSet.weight = value
                }

                saveChanges()
            }
        )
    }

    private func repsBinding(
        for workoutSet: WorkoutSet
    ) -> Binding<String> {

        let id = workoutSet.persistentModelID

        return Binding(
            get: {
                repsDrafts[id] ??
                workoutSet.reps.map { String($0) } ?? ""
            },
            set: { newValue in
                repsDrafts[id] = newValue
                workoutSet.reps = Int(newValue)
                saveChanges()
            }
        )
    }

    // MARK: - Set Management

    private func addSet(to exercise: SessionExercise) {
        workoutEditor.addSet(to: exercise)
    }

    private func removeSet(
        _ workoutSet: WorkoutSet,
        from exercise: SessionExercise
    ) {
        guard exercise.sets.count > 1 else { return }
        clearDrafts(for: workoutSet)
        workoutEditor.removeSet(workoutSet, from: exercise)
    }

    private func clearDrafts(for workoutSet: WorkoutSet) {
        weightDrafts.removeValue(forKey: workoutSet.persistentModelID)
        repsDrafts.removeValue(forKey: workoutSet.persistentModelID)
    }

    // MARK: - Workout Actions

    private func finishWorkout() {
        session.endDate = Date()
        session.isCompleted = true

        do {
            try modelContext.save()
            workoutSessionManager.clearSession()
            dismiss()
        } catch {
            print("Failed to finish workout: \(error)")
        }
    }

    private func discardWorkout() {
        modelContext.delete(session)

        do {
            try modelContext.save()
            workoutSessionManager.clearSession()
            dismiss()
        } catch {
            print("Failed to discard workout: \(error)")
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save workout: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ActiveWorkoutView(
            session: WorkoutSession(name: "Chest Day")
        )
    }
    .environmentObject(WorkoutSessionManager())
    .modelContainer(for: [
        Exercise.self,
        WorkoutSession.self,
        SessionExercise.self,
        WorkoutSet.self
    ])
}
