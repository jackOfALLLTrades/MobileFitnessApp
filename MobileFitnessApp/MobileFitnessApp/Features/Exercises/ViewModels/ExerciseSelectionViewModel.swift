//
//  ExerciseSelectionViewModel.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation
import Observation
import SwiftData

/// Holds uncommitted selection and browsing preferences for the picker.
@MainActor
@Observable
final class ExerciseSelectionViewModel {
    private(set) var draftSelection: [Exercise]
    var searchText = ""
    var sortOption: ExerciseSortOption = .muscleGroup

    init(selectedExercises: [Exercise]) {
        draftSelection = selectedExercises
    }

    func isSelected(_ exercise: Exercise) -> Bool {
        draftSelection.contains { $0.persistentModelID == exercise.persistentModelID }
    }

    func isAlreadySelectedElsewhere(
        _ exercise: Exercise,
        selectedExercises: [Exercise],
        replacementTargetID: PersistentIdentifier?
    ) -> Bool {
        guard let replacementTargetID else { return false }
        return selectedExercises.contains {
            $0.persistentModelID == exercise.persistentModelID &&
            $0.persistentModelID != replacementTargetID
        }
    }

    func toggleExercise(_ exercise: Exercise) {
        if isSelected(exercise) {
            removeExercise(exercise)
        } else {
            draftSelection.append(exercise)
        }
    }

    func removeExercise(_ exercise: Exercise) {
        draftSelection.removeAll { $0.persistentModelID == exercise.persistentModelID }
    }
}
