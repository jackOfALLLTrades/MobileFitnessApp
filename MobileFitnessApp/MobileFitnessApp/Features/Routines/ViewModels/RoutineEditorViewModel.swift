//
//  RoutineEditorViewModel.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation
import SwiftData
import Observation

/// Owns the routine draft; edits reach saved models only when Save is selected.
@MainActor
@Observable
final class RoutineEditorViewModel {
    private let routine: Routine?
    var routineName: String
    var selectedExercises: [Exercise]
    private(set) var setRowIDs: [PersistentIdentifier: [UUID]]

    init(routine: Routine? = nil) {
        self.routine = routine
        let existingExercises = (routine?.exercises ?? []).sorted { $0.order < $1.order }
        routineName = routine?.name ?? ""
        selectedExercises = existingExercises.map { $0.exercise }
        setRowIDs = Dictionary(uniqueKeysWithValues: existingExercises.map { link in
            (link.exercise.persistentModelID, (0..<max(1, link.plannedSets)).map { _ in UUID() })
        })
    }

    private var trimmedName: String {
        routineName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool {
        !trimmedName.isEmpty && !selectedExercises.isEmpty
    }

    func syncSetRows() {
        for exercise in selectedExercises {
            let id = exercise.persistentModelID

            if setRowIDs[id] == nil {
                setRowIDs[id] = (0..<3).map { _ in UUID() }
            }
        }
    }

    func replaceExercise(
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

    func addSet(for exercise: Exercise) {
        let id = exercise.persistentModelID

        setRowIDs[id, default: []].append(UUID())
    }

    func removeSet(
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

    func removeExercise(_ exercise: Exercise) {
        let id = exercise.persistentModelID

        selectedExercises.removeAll {
            $0.persistentModelID == id
        }

        setRowIDs.removeValue(forKey: id)
    }

    func save(in modelContext: ModelContext, existingRoutines: [Routine]) throws {
        let savedRoutine: Routine

        if let routine {
            savedRoutine = routine
            savedRoutine.name = trimmedName
        } else {
            let nextOrder = (existingRoutines.map(\.sortOrder).max() ?? -1) + 1

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

        try modelContext.save()
    }
}
