//
//  WorkoutExercise.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import Foundation
import SwiftData

struct WorkoutExerciseNote: Codable, Identifiable {
    var id = UUID()
    var text = ""
}

/// An exercise snapshot within a workout; its logged sets belong to this attempt.
@Model
final class WorkoutExercise {
    var exerciseName: String
    var notes: String?
    var noteEntries: [WorkoutExerciseNote]?
    var loggingModeValue: String?

    var loggingMode: ExerciseLoggingMode {
        get {
            if let loggingModeValue,
               let mode = ExerciseLoggingMode(rawValue: loggingModeValue) {
                return mode
            }

            let catalogMode = ExerciseCatalog.loggingMode(for: exerciseName)
            // Older bodyweight records may contain weight entered before reps-only logging.
            if catalogMode == .bodyweight && sets.contains(where: { $0.weight != nil }) {
                return .weighted
            }
            return catalogMode
        }
        set { loggingModeValue = newValue.rawValue }
    }

    var visibleNotes: [WorkoutExerciseNote] {
        if let noteEntries { return noteEntries }
        guard let notes, !notes.isEmpty else { return [] }

        // Give a legacy single note a stable identity until it is edited or removed.
        return [WorkoutExerciseNote(id: Self.legacyNoteID, text: notes)]
    }

    private static let legacyNoteID = UUID()
    var order: Int
    var session: WorkoutSession?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workoutExercise)
    var sets: [WorkoutSet] = []

    init(exerciseName: String, order: Int, loggingMode: ExerciseLoggingMode? = nil) {
        self.exerciseName = exerciseName
        self.order = order
        self.loggingModeValue = loggingMode?.rawValue
    }
}
