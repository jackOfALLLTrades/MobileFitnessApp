//
//  ExerciseBrowser.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation

enum ExerciseSortOption: String, CaseIterable {
    case muscleGroup = "Muscle Group"
    case alphabetical = "Alphabetical"
}

struct ExerciseGroup: Identifiable {
    let name: String
    let exercises: [Exercise]

    var id: String { name }
}

/// Shares exercise search and picker grouping without owning selection or persistence.
enum ExerciseBrowser {
    static let muscleGroupOrder = [
        "Chest",
        "Back",
        "Shoulders",
        "Biceps",
        "Triceps",
        "Legs",
        "Core",
        "Other"
    ]

    static func filtered(_ exercises: [Exercise], searchText: String) -> [Exercise] {
        guard !searchText.isEmpty else {
            return exercises
        }

        return exercises.filter {
            $0.name.localizedStandardContains(searchText) ||
            ($0.muscleGroup?.localizedStandardContains(searchText) ?? false)
        }
    }

    static func groups(_ exercises: [Exercise], searchText: String, sortOption: ExerciseSortOption) -> [ExerciseGroup] {
        let filteredExercises = filtered(exercises, searchText: searchText)
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

}
