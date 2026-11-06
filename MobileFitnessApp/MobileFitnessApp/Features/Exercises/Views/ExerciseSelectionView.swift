//
//  ExerciseSelectionView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

private enum ExerciseSortOption: String, CaseIterable {
    case muscleGroup = "Muscle Group"
    case alphabetical = "Alphabetical"
}

private struct ExerciseGroup: Identifiable {
    let name: String
    let exercises: [Exercise]

    var id: String { name }
}

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Exercise.name)
    private var exercises: [Exercise]

    @Binding private var selectedExercises: [Exercise]

    @State private var draftSelection: [Exercise]
    @State private var searchText = ""
    @State private var showingAddExercise = false
    @State private var sortOption: ExerciseSortOption = .muscleGroup

    private let muscleGroupOrder = [
        "Chest",
        "Back",
        "Shoulders",
        "Biceps",
        "Triceps",
        "Legs",
        "Core",
        "Other"
    ]

    private let replacementTargetID: PersistentIdentifier?
    private let onReplace: ((Exercise) -> Void)?

    init(
        selectedExercises: Binding<[Exercise]>,
        replacementTargetID: PersistentIdentifier? = nil,
        onReplace: ((Exercise) -> Void)? = nil
    ) {
        self._selectedExercises = selectedExercises
        self._draftSelection = State(
            initialValue: selectedExercises.wrappedValue
        )
        self.replacementTargetID = replacementTargetID
        self.onReplace = onReplace
    }

    private var filteredExercises: [Exercise] {
        guard !searchText.isEmpty else {
            return exercises
        }

        return exercises.filter {
            $0.name.localizedStandardContains(searchText) ||
            ($0.muscleGroup?.localizedStandardContains(searchText) ?? false)
        }
    }

    private var exerciseGroups: [ExerciseGroup] {
        if sortOption == .alphabetical {
            let sorted = filteredExercises.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }

            return sorted.isEmpty
                ? []
                : [ExerciseGroup(name: "All Exercises", exercises: sorted)]
        }

        let grouped = Dictionary(grouping: filteredExercises) { exercise in
            let rawGroup = exercise.muscleGroup?
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let rawGroup, !rawGroup.isEmpty else {
                return "Other"
            }

            return muscleGroupOrder.first {
                $0.caseInsensitiveCompare(rawGroup) == .orderedSame
            } ?? rawGroup
        }

        let standardGroups = muscleGroupOrder.filter {
            grouped[$0] != nil
        }

        let additionalGroups = grouped.keys
            .filter { !muscleGroupOrder.contains($0) }
            .sorted()

        let orderedGroups = standardGroups + additionalGroups

        return orderedGroups.compactMap { groupName in
            guard let groupExercises = grouped[groupName] else {
                return nil
            }

            let sortedExercises = groupExercises.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }

            return ExerciseGroup(
                name: groupName,
                exercises: sortedExercises
            )
        }
    }

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
        .navigationTitle(
            replacementTargetID == nil
                ? "Select Exercises"
                : "Replace Exercise"
        )
        .searchable(text: $searchText, prompt: "Search exercises")
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
                    Picker("Sort By", selection: $sortOption) {
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
                        selectedExercises = draftSelection
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

    private func exerciseRow(_ exercise: Exercise) -> some View {
        Button {
            if replacementTargetID != nil {
                guard !isAlreadySelectedElsewhere(exercise) else {
                    return
                }

                onReplace?(exercise)
                dismiss()
            } else {
                toggleExercise(exercise)
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(exercise.name)
                            .foregroundStyle(.primary)

                        if !exercise.isBuiltIn {
                            Text("Custom")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(.quaternary)
                                .clipShape(Capsule())
                        }
                    }

                    if sortOption == .alphabetical,
                       let muscleGroup = exercise.muscleGroup,
                       !muscleGroup.isEmpty {
                        Text(muscleGroup)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(
                    systemName: replacementTargetID != nil
                        ? (
                            exercise.persistentModelID == replacementTargetID
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        : (
                            isSelected(exercise)
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                )
                .foregroundStyle(
                    replacementTargetID != nil
                        ? (
                            exercise.persistentModelID == replacementTargetID
                                ? .blue
                                : .secondary
                        )
                        : (
                            isSelected(exercise) ? .blue : .secondary
                        )
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

    private func isSelected(_ exercise: Exercise) -> Bool {
        draftSelection.contains {
            $0.persistentModelID == exercise.persistentModelID
        }
    }
    
    private func isAlreadySelectedElsewhere(
        _ exercise: Exercise
    ) -> Bool {
        guard replacementTargetID != nil else {
            return false
        }

        return selectedExercises.contains {
            $0.persistentModelID == exercise.persistentModelID &&
            $0.persistentModelID != replacementTargetID
        }
    }

    private func toggleExercise(_ exercise: Exercise) {
        if let index = draftSelection.firstIndex(where: {
            $0.persistentModelID == exercise.persistentModelID
        }) {
            draftSelection.remove(at: index)
        } else {
            draftSelection.append(exercise)
        }
    }

    private func deleteExercise(_ exercise: Exercise) {
        draftSelection.removeAll {
            $0.persistentModelID == exercise.persistentModelID
        }

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
