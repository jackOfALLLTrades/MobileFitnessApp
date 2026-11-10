//
//  Routine.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import Foundation
import SwiftData

/// A reusable workout blueprint, separate from logged workout records.
@Model
final class Routine {
    var name: String
    var sortOrder: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \RoutineExercise.routine)
    var exercises: [RoutineExercise] = []

    @Relationship(deleteRule: .nullify, inverse: \WorkoutSession.sourceRoutine)
    var workoutSessions: [WorkoutSession] = []

    init(name: String, sortOrder: Int = 0) {
        self.name = name
        self.sortOrder = sortOrder
    }
}
