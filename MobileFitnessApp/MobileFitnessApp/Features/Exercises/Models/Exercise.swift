//
//  Exercise.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//

import Foundation
import SwiftData

enum ExerciseLoggingMode: String, CaseIterable {
    case weighted = "Weight and Reps"
    case bodyweight = "Reps Only"
    case timed = "Seconds"

    var showsWeight: Bool { self == .weighted }
    var countHeading: String { self == .timed ? "SECS" : "REPS" }
}

/// A lift in the library, shared by routine blueprints.
@Model
final class Exercise {
    var name: String
    var muscleGroup: String?
    var isBuiltIn: Bool = false
    var loggingModeValue: String?

    var loggingMode: ExerciseLoggingMode {
        get {
            loggingModeValue.flatMap(ExerciseLoggingMode.init(rawValue:))
                ?? ExerciseCatalog.loggingMode(for: name)
        }
        set { loggingModeValue = newValue.rawValue }
    }

    @Relationship(deleteRule: .cascade, inverse: \RoutineExercise.exercise)
    var routineUsages: [RoutineExercise] = []

    init(
        name: String,
        muscleGroup: String? = nil,
        isBuiltIn: Bool = false,
        loggingMode: ExerciseLoggingMode? = nil
    ) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.isBuiltIn = isBuiltIn
        self.loggingModeValue = loggingMode?.rawValue
    }
}
