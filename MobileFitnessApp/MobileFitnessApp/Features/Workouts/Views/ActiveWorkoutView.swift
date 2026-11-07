//
//  ActiveWorkoutView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    let session: WorkoutSession

    var body: some View {
        ActiveWorkoutContent(session: session, modelContext: modelContext)
    }
}

private struct ActiveWorkoutContent: View {

    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var workoutSessionManager: WorkoutSessionManager

    @Query(sort: \WorkoutSession.startDate, order: .reverse)
    private var workoutSessions: [WorkoutSession]

    @Query(sort: \Exercise.name)
    private var availableExercises: [Exercise]

    let session: WorkoutSession

    // MARK: - Presentation State

    @State private var showingFinishConfirmation = false
    @State private var showingDiscardConfirmation = false
    @State private var showingExerciseSelection = false
    @State private var showingReplacementSelection = false
    @State private var showingReorderExercises = false
    @State private var showingDeleteExerciseConfirmation = false
    @State private var showingReplacementUnavailable = false
    @State private var showingSettingsMessage = false

    @State private var selectedExercises: [Exercise] = []
    @State private var exercisesToReorder: [WorkoutExercise] = []

    @State private var exerciseBeingReplaced: WorkoutExercise?
    @State private var exerciseBeingDeleted: WorkoutExercise?
    @State private var replacementTargetID: PersistentIdentifier?

    // MARK: - Editing State

    @State private var workoutEditor: ActiveWorkoutViewModel

    // MARK: - Initialization

    init(session: WorkoutSession, modelContext: ModelContext) {
        self.session = session
        _workoutEditor = State(initialValue: ActiveWorkoutViewModel(modelContext: modelContext))
    }

    // MARK: - Derived Values

    private var orderedExercises: [WorkoutExercise] {
        session.exercises.sorted { $0.order < $1.order }
    }

    // MARK: - Content

    var body: some View {
        List {

            // MARK: - Workout Header

            WorkoutHeaderView(
                startDate: session.startDate,
                exerciseCount: orderedExercises.count
            )

            // MARK: - Exercises

            ForEach(orderedExercises) { exercise in
                WorkoutExerciseSection(
                    exercise: exercise,
                    previousPerformance: { setOrder in
                        PreviousPerformanceLookup().previousPerformance(
                            for: exercise,
                            setOrder: setOrder,
                            before: session,
                            in: workoutSessions
                        )
                    },
                    weightBinding: { workoutSet in
                        workoutEditor.weightBinding(for: workoutSet)
                    },
                    repsBinding: { workoutSet in
                        workoutEditor.repsBinding(for: workoutSet)
                    },
                    onToggleCompleted: { workoutSet in
                        workoutEditor.toggleCompleted(workoutSet)
                    },
                    onRemoveSet: { workoutSet in
                        workoutEditor.removeSet(workoutSet, from: exercise)
                    },
                    onAddSet: {
                        workoutEditor.addSet(to: exercise)
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
            Section {
                Text("Sets can be removed by swiping left.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // MARK: - Workout Actions

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

        // MARK: - Exercise Selection

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

        // MARK: - Exercise Reordering

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

        // MARK: - Exercise Replacement

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

        // MARK: - Confirmation Dialogs

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
                    workoutEditor.deleteExercise(exercise, from: session)
                }

                exerciseBeingDeleted = nil
            }

            Button("Cancel", role: .cancel) {
                exerciseBeingDeleted = nil
            }
        } message: {
            Text("This will remove the exercise and all of its sets from this workout.")
        }

        // MARK: - Alerts

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

    // MARK: - Exercise Management

    private func prepareExerciseSelection() {
        selectedExercises = workoutEditor.selectedExercises(
            in: session, from: availableExercises
        )

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
        for exercise: WorkoutExercise
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

        selectedExercises = workoutEditor.selectedExercises(
            in: session, from: availableExercises
        )

        exerciseBeingReplaced = exercise
        replacementTargetID = targetExercise.persistentModelID
        showingReplacementSelection = true
    }

    // MARK: - Workout Actions

    private func finishWorkout() {
        do {
            try workoutSessionManager.finishWorkout(session, in: modelContext)
            dismiss()
        } catch {
            print("Failed to finish workout: \(error)")
        }
    }

    private func discardWorkout() {
        do {
            try workoutSessionManager.discardWorkout(session, in: modelContext)
            dismiss()
        } catch {
            print("Failed to discard workout: \(error)")
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
        WorkoutExercise.self,
        WorkoutSet.self
    ])
}
