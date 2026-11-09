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

    init(exerciseName: String, order: Int) {
        self.exerciseName = exerciseName
        self.order = order
    }
}
