//
//  ExerciseSelectionView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

struct ExerciseSelectionView: View {
    // MARK: - Dependencies

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Exercise.name)
    private var exercises: [Exercise]

    // MARK: - Selection and Presentation State

    @Binding private var selectedExercises: [Exercise]

    @State private var selection: ExerciseSelectionViewModel
    @State private var showingAddExercise = false

    private let replacementTargetID: PersistentIdentifier?
    private let onReplace: ((Exercise) -> Void)?

    // MARK: - Initialization

    init(
        selectedExercises: Binding<[Exercise]>,
        replacementTargetID: PersistentIdentifier? = nil,
        onReplace: ((Exercise) -> Void)? = nil
    ) {
        self._selectedExercises = selectedExercises
        self._selection = State(initialValue: ExerciseSelectionViewModel(selectedExercises: selectedExercises.wrappedValue))
        self.replacementTargetID = replacementTargetID
        self.onReplace = onReplace
    }

    // MARK: - Derived Values

    private var exerciseGroups: [ExerciseGroup] {
        ExerciseBrowser.groups(exercises, searchText: selection.searchText, sortOption: selection.sortOption)
    }

    // MARK: - Content

    var body: some View {
        List {
            if exerciseGroups.isEmpty {
                ContentUnavailableView(
                    "No Exercises Found",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search.")
                )
            } else {
                ForEach(exerciseGroups) { group in
                    Section(group.name) {
                        ForEach(group.exercises) { exercise in
                            exerciseRow(exercise)
                        }
                    }
                }

                Section {
                    Text("Custom exercises can be deleted by swiping left.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .themeBackground()
        .navigationTitle(
            replacementTargetID == nil
                ? "Select Exercises"
                : "Replace Exercise"
        )
        .searchable(text: $selection.searchText, prompt: "Search exercises")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingAddExercise = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort By", selection: $selection.sortOption) {
                        ForEach(ExerciseSortOption.allCases, id: \.self) {
                            option in

                            Text(option.rawValue)
                                .tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                if replacementTargetID == nil {
                    Button("Done") {
                        selectedExercises = selection.draftSelection
                        dismiss()
                    }
                } else {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
        .task {
            ExerciseCatalog.seed(into: modelContext)
        }
    }

    // MARK: - Exercise Rows

    private func exerciseRow(_ exercise: Exercise) -> some View {
        Button {
            if replacementTargetID != nil {
                guard !isAlreadySelectedElsewhere(exercise) else {
                    return
                }

                onReplace?(exercise)
                dismiss()
            } else {
                selection.toggleExercise(exercise)
            }
        } label: {
            ExerciseSelectionRow(
                exercise: exercise,
                isSelected: replacementTargetID.map { exercise.persistentModelID == $0 }
                    ?? selection.isSelected(exercise),
                showsMuscleGroup: selection.sortOption == .alphabetical
            )
        }
        .buttonStyle(.plain)
        .themeListRow()
        .disabled(isAlreadySelectedElsewhere(exercise))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !exercise.isBuiltIn {
                Button(role: .destructive) {
                    deleteExercise(exercise)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    // MARK: - Selection Rules

    private func isAlreadySelectedElsewhere(
        _ exercise: Exercise
    ) -> Bool {
        selection.isAlreadySelectedElsewhere(
            exercise,
            selectedExercises: selectedExercises,
            replacementTargetID: replacementTargetID
        )
    }

    // MARK: - Persistence

    private func deleteExercise(_ exercise: Exercise) {
        selection.removeExercise(exercise)
        modelContext.delete(exercise)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete exercise: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseSelectionView(selectedExercises: .constant([]))
    }
    .modelContainer(for: [
        Exercise.self,
        Routine.self,
        RoutineExercise.self
    ])
}
