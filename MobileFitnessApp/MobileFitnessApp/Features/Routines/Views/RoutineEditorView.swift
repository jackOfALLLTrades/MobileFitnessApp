//
//  RoutineEditorView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

private enum RoutineEditorSheet: Identifiable {
    case selectExercises
    case reorder
    case replace(Exercise, id: UUID)

    var id: String {
        switch self {
        case .selectExercises:
            return "selectExercises"
        case .reorder:
            return "reorder"
        case .replace(_, let id):
            return id.uuidString
        }
    }
}

struct RoutineEditorView: View {
    // MARK: - Dependencies

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var routines: [Routine]
    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light

    // MARK: - Editing and Presentation State

    private let isEditing: Bool
    @State private var editor: RoutineEditorViewModel
    @State private var activeSheet: RoutineEditorSheet?

    // MARK: - Initialization

    init(routine: Routine? = nil) {
        isEditing = routine != nil
        _editor = State(initialValue: RoutineEditorViewModel(routine: routine))
    }

    // MARK: - Content

    var body: some View {
        Form {
            Section("Routine Information") {
                TextField("Routine Name", text: $editor.routineName)
                    .themeListRow()
            }

            Section {
                Button {
                    activeSheet = .selectExercises
                } label: {
                    Label("Select Exercises", systemImage: "plus")
                        .foregroundStyle(theme.accent)
                }
                .themeListRow()
            }

            if editor.selectedExercises.isEmpty {
                Section("Exercises") {
                    Text("No exercises selected.")
                        .foregroundStyle(.secondary)
                        .themeListRow()
                }
            } else {
                ForEach(
                    editor.selectedExercises,
                    id: \.persistentModelID
                ) { exercise in
                    RoutineExerciseSection(
                        exercise: exercise,
                        rows: editor.setRowIDs[exercise.persistentModelID] ?? [],
                        onReorder: { activeSheet = .reorder },
                        onReplace: { activeSheet = .replace(exercise, id: UUID()) },
                        onDelete: { editor.removeExercise(exercise) },
                        onRemoveSet: { editor.removeSet(for: exercise, rowID: $0) },
                        onAddSet: { editor.addSet(for: exercise) }
                    )
                }
                Section {
                    Text("Sets can be removed by swiping left.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .themeListRow()
                }
            }
        }
        .themeBackground()
        .sheet(item: $activeSheet) { sheet in
            NavigationStack {
                switch sheet {
                case .selectExercises:
                    ExerciseSelectionView(selectedExercises: $editor.selectedExercises)

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
            .tint(theme.accent)
            .preferredColorScheme(theme.colorScheme)
        }
        .onChange(of: editor.selectedExercises.map(\.persistentModelID)) {
            _, _ in
            editor.syncSetRows()
        }
        .tint(theme.accent)
        .preferredColorScheme(theme.colorScheme)
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

    // MARK: - Persistence

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
