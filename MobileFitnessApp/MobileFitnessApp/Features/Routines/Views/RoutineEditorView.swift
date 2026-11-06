//
//  RoutineEditorView.swift
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

struct RoutineEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var routines: [Routine]

    private let isEditing: Bool
    @State private var editor: RoutineEditorViewModel
    @State private var activeSheet: RoutineEditorSheet?

    init(routine: Routine? = nil) {
        isEditing = routine != nil
        _editor = State(initialValue: RoutineEditorViewModel(routine: routine))
    }

    var body: some View {
        Form {
            Section("Routine Information") {
                TextField("Routine Name", text: $editor.routineName)
            }

            Section {
                NavigationLink {
                    ExerciseSelectionView(
                        selectedExercises: $editor.selectedExercises
                    )
                } label: {
                    Label("Select Exercises", systemImage: "plus")
                }
            }

            if editor.selectedExercises.isEmpty {
                Section("Exercises") {
                    Text("No exercises selected.")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(
                    editor.selectedExercises,
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
                        exercises: $editor.selectedExercises,
                        exerciseName: { exercise in exercise.name }
                    )

                case .replace(let exercise, _):
                    ExerciseSelectionView(
                        selectedExercises: $editor.selectedExercises,
                        replacementTargetID: exercise.persistentModelID
                    ) { replacement in
                        editor.replaceExercise(exercise, with: replacement)
                    }
                }
            }
        }
        .onChange(of: editor.selectedExercises.map(\.persistentModelID)) {
            _, _ in
            editor.syncSetRows()
        }
        .navigationTitle(isEditing ? "Edit Routine" : "New Routine")
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
                .disabled(!editor.isValid)
            }
        }
    }

    private func exerciseSection(for exercise: Exercise) -> some View {
        let id = exercise.persistentModelID
        let rows = editor.setRowIDs[id] ?? []

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
                        editor.removeExercise(exercise)
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
            SetColumnHeadings(style: .routine)

            // Individual set rows.
            ForEach(Array(rows.enumerated()), id: \.element) { index, rowID in
                RoutineSetRow(number: index + 1)
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: false
                ) {
                    if rows.count > 1 {
                        Button(role: .destructive) {
                            editor.removeSet(for: exercise, rowID: rowID)
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
                editor.addSet(for: exercise)
            } label: {
                Label("Add Set", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .listRowSeparator(.hidden)
        }
    }

    private func saveRoutine() {
        do {
            try editor.save(in: modelContext, existingRoutines: routines)
            dismiss()
        } catch {
            print("Failed to save routine: \(error)")
        }
    }

}

#Preview {
    NavigationStack {
        RoutineEditorView()
    }
    .modelContainer(for: [
        Exercise.self,
        Routine.self,
        RoutineExercise.self
    ])
}
