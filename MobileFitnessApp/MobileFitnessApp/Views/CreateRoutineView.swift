//
//  CreateRoutineView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

private enum RoutineEditorSheet: Identifiable {
    case reorder
    case replace(Exercise, id: UUID)

    var id: String {
        switch self {
        case .reorder:
            return "reorder"
        case .replace(_, let id):
            return id.uuidString
        }
    }
}

struct CreateRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var routines: [Routine]

    private let routine: Routine?

    @State private var routineName: String
    @State private var selectedExercises: [Exercise]
    @State private var setRowIDs: [PersistentIdentifier: [UUID]]
    @State private var activeSheet: RoutineEditorSheet?

    init(routine: Routine? = nil) {
        self.routine = routine

        let existingExercises = (routine?.exercises ?? [])
            .sorted { $0.order < $1.order }

        _routineName = State(initialValue: routine?.name ?? "")

        _selectedExercises = State(
            initialValue: existingExercises.map { $0.exercise }
        )

        _setRowIDs = State(
            initialValue: Dictionary(
                uniqueKeysWithValues: existingExercises.map { link in
                    (
                        link.exercise.persistentModelID,
                        (0..<max(1, link.plannedSets)).map { _ in UUID() }
                    )
                }
            )
        )
    }

    private var trimmedName: String {
        routineName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValid: Bool {
        !trimmedName.isEmpty && !selectedExercises.isEmpty
    }

    var body: some View {
        Form {
            Section("Routine Information") {
                TextField("Routine Name", text: $routineName)
            }

            Section {
                NavigationLink {
                    ExerciseSelectionView(
                        selectedExercises: $selectedExercises
                    )
                } label: {
                    Label("Select Exercises", systemImage: "plus")
                }
            }

            if selectedExercises.isEmpty {
                Section("Exercises") {
                    Text("No exercises selected.")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(
                    selectedExercises,
                    id: \.persistentModelID
                ) { exercise in
                    exerciseSection(for: exercise)
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            NavigationStack {
                switch sheet {
                case .reorder:
                    ReorderExercisesView(
                        exercises: $selectedExercises,
                        exerciseName: { exercise in exercise.name }
                    )

                case .replace(let exercise, _):
                    ExerciseSelectionView(
                        selectedExercises: $selectedExercises,
                        replacementTargetID: exercise.persistentModelID
                    ) { replacement in
                        replaceExercise(exercise, with: replacement)
                    }
                }
            }
        }
        .onChange(of: selectedExercises.map(\.persistentModelID)) {
            _, _ in
            syncSetRows()
        }
        .navigationTitle(routine == nil ? "New Routine" : "Edit Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveRoutine()
                }
                .disabled(!isValid)
            }
        }
    }

    private func exerciseSection(for exercise: Exercise) -> some View {
        let id = exercise.persistentModelID
        let rows = setRowIDs[id] ?? []

        return Section {
            // Exercise name and management menu.
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Menu {
                    Button {
                        activeSheet = .reorder
                    } label: {
                        Label(
                            "Reorder",
                            systemImage: "arrow.up.arrow.down"
                        )
                    }

                    Button {
                        activeSheet = .replace(exercise, id: UUID())
                    } label: {
                        Label(
                            "Replace Exercise",
                            systemImage: "arrow.left.arrow.right"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        removeExercise(exercise)
                    } label: {
                        Label(
                            "Delete Exercise",
                            systemImage: "trash"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
            }
            .listRowSeparator(.hidden)

            // Column headings.
            HStack(spacing: 12) {
                Text("SET")
                    .frame(width: 44, alignment: .leading)

                Text("LBS")
                    .frame(maxWidth: .infinity)

                Text("REPS")
                    .frame(maxWidth: .infinity)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .listRowSeparator(.hidden)

            // Individual set rows.
            ForEach(Array(rows.enumerated()), id: \.element) { index, rowID in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.subheadline.weight(.medium))
                        .frame(width: 44, alignment: .leading)

                    Text("—")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.tertiary)

                    Text("—")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.tertiary)
                }
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: false
                ) {
                    if rows.count > 1 {
                        Button(role: .destructive) {
                            removeSet(for: exercise, rowID: rowID)
                        } label: {
                            Label(
                                "Remove Set",
                                systemImage: "trash"
                            )
                        }
                    }
                }
            }

            // Add set button.
            Button {
                addSet(for: exercise)
            } label: {
                Label("Add Set", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .listRowSeparator(.hidden)
        }
    }

    private func syncSetRows() {
        for exercise in selectedExercises {
            let id = exercise.persistentModelID

            if setRowIDs[id] == nil {
                setRowIDs[id] = (0..<3).map { _ in UUID() }
            }
        }
    }

    private func replaceExercise(
        _ oldExercise: Exercise,
        with newExercise: Exercise
    ) {
        guard !selectedExercises.contains(where: {
            $0.persistentModelID == newExercise.persistentModelID
        }) else {
            return
        }

        guard let index = selectedExercises.firstIndex(where: {
            $0.persistentModelID == oldExercise.persistentModelID
        }) else {
            return
        }

        let oldID = oldExercise.persistentModelID
        let newID = newExercise.persistentModelID

        let existingRows = setRowIDs[oldID] ?? (0..<3).map { _ in UUID() }

        selectedExercises[index] = newExercise

        setRowIDs[newID] = existingRows
        setRowIDs.removeValue(forKey: oldID)
    }

    private func addSet(for exercise: Exercise) {
        let id = exercise.persistentModelID

        setRowIDs[id, default: []].append(UUID())
    }

    private func removeSet(
        for exercise: Exercise,
        rowID: UUID
    ) {
        let id = exercise.persistentModelID

        guard let rows = setRowIDs[id],
              rows.count > 1 else {
            return
        }

        setRowIDs[id]?.removeAll { $0 == rowID }
    }

    private func removeExercise(_ exercise: Exercise) {
        let id = exercise.persistentModelID

        selectedExercises.removeAll {
            $0.persistentModelID == id
        }

        setRowIDs.removeValue(forKey: id)
    }

    private func saveRoutine() {
        let savedRoutine: Routine

        if let routine {
            savedRoutine = routine
            savedRoutine.name = trimmedName
        } else {
            let nextOrder = (routines.map(\.sortOrder).max() ?? -1) + 1

            savedRoutine = Routine(
                name: trimmedName,
                sortOrder: nextOrder
            )

            modelContext.insert(savedRoutine)
        }

        let existingLinks = savedRoutine.exercises

        // Remove exercise associations that are no longer selected.
        for link in existingLinks {
            let isStillSelected = selectedExercises.contains {
                $0.persistentModelID == link.exercise.persistentModelID
            }

            if !isStillSelected {
                modelContext.delete(link)
            }
        }

        // Update existing associations or create new ones.
        for (index, exercise) in selectedExercises.enumerated() {
            let setCount = setRowIDs[
                exercise.persistentModelID,
                default: (0..<3).map { _ in UUID() }
            ].count

            if let existingLink = existingLinks.first(where: {
                $0.exercise.persistentModelID == exercise.persistentModelID
            }) {
                existingLink.order = index
                existingLink.plannedSets = max(1, setCount)
            } else {
                let newLink = RoutineExercise(
                    exercise: exercise,
                    order: index,
                    plannedSets: max(1, setCount)
                )

                newLink.routine = savedRoutine
                modelContext.insert(newLink)
            }
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save routine: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        CreateRoutineView()
    }
    .modelContainer(for: [
        Exercise.self,
        Routine.self,
        RoutineExercise.self
    ])
}
