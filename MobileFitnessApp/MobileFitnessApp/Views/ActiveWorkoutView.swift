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
    @State private var showingSettingsMessage = false

    @State private var selectedExercises: [Exercise] = []

    @State private var weightDrafts: [PersistentIdentifier: String] = [:]
    @State private var repsDrafts: [PersistentIdentifier: String] = [:]

    private var orderedExercises: [SessionExercise] {
        session.exercises.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            // MARK: Workout Header

            Section {
                HStack(alignment: .center) {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(
                                elapsedTime(
                                    since: session.startDate,
                                    now: context.date
                                )
                            )
                            .font(.title2.weight(.semibold).monospacedDigit())

                            Text("WORKOUT DURATION")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(orderedExercises.count)")
                            .font(.title2.weight(.semibold))

                        Text("EXERCISES")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                .listRowSeparator(.hidden)
            }

            // MARK: Exercises

            ForEach(orderedExercises) { exercise in
                Section {
                    Text(exercise.exerciseName)
                        .font(.headline)
                        .listRowSeparator(.hidden)

                    // Column headings
                    HStack(spacing: 8) {
                        Text("SET")
                            .frame(width: 30, alignment: .center)
                            .padding(.leading, 4)

                        Text("PREVIOUS")
                            .frame(width: 82, alignment: .center)

                        Text("LBS")
                            .frame(maxWidth: .infinity)

                        Text("REPS")
                            .frame(maxWidth: .infinity)

                        Spacer()
                            .frame(width: 28)
                    }
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)

                    // Individual set rows
                    ForEach(
                        exercise.sets.sorted { $0.order < $1.order }
                    ) { workoutSet in
                        WorkoutSetRow(
                            workoutSet: workoutSet,
                            previousPerformance: previousPerformance(
                                for: exercise,
                                setOrder: workoutSet.order
                            ),
                            weightText: weightBinding(for: workoutSet),
                            repsText: repsBinding(for: workoutSet),
                            onToggleCompleted: {
                                workoutSet.isCompleted.toggle()
                                saveChanges()
                            }
                        )
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: false
                        ) {
                            if exercise.sets.count > 1 {
                                Button(role: .destructive) {
                                    removeSet(
                                        workoutSet,
                                        from: exercise
                                    )
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    }

                    addSetButton(for: exercise)
                }
            }

            // MARK: Workout Actions

            Section {
                VStack(spacing: 12) {
                    Button {
                        prepareExerciseSelection()
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.quaternary.opacity(0.5))
                    )

                    HStack {
                        Button {
                            showingSettingsMessage = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.quaternary.opacity(0.5))
                        )

                        Spacer()
                            .frame(width: 12)

                        Button {
                            showingDiscardConfirmation = true
                        } label: {
                            Label {
                                Text("Discard")
                            } icon: {
                                Image(systemName: "trash")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.quaternary.opacity(0.5))
                        )
                    }
                }
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
            }
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

    // MARK: - Workout Duration

    private func elapsedTime(
        since startDate: Date,
        now: Date
    ) -> String {
        let totalSeconds = max(
            0,
            Int(now.timeIntervalSince(startDate))
        )

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(
            format: "%02d:%02d:%02d",
            hours,
            minutes,
            seconds
        )
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
        let existingNames = Set(
            session.exercises.map {
                $0.exerciseName.lowercased()
            }
        )

        let newExercises = selectedExercises.filter {
            !existingNames.contains($0.name.lowercased())
        }

        guard !newExercises.isEmpty else {
            selectedExercises = []
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

        selectedExercises = []
        saveChanges()
    }

    // MARK: - Add Set

    private func addSetButton(
        for exercise: SessionExercise
    ) -> some View {
        Button {
            addSet(to: exercise)
        } label: {
            Label("Add Set", systemImage: "plus")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.quaternary.opacity(0.5))
        )
        .listRowSeparator(.hidden)
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
        let nextOrder = (exercise.sets.map(\.order).max() ?? -1) + 1

        let workoutSet = WorkoutSet(order: nextOrder)
        workoutSet.sessionExercise = exercise

        modelContext.insert(workoutSet)
        saveChanges()
    }

    private func removeSet(
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

        weightDrafts.removeValue(
            forKey: workoutSet.persistentModelID
        )

        repsDrafts.removeValue(
            forKey: workoutSet.persistentModelID
        )

        for (index, set) in remainingSets.enumerated() {
            set.order = index
        }

        saveChanges()
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



