//
//  WorkoutSet.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var weight: Double?
    var reps: Int?
    var isCompleted: Bool

    var sessionExercise: SessionExercise?

    init(weight: Double? = nil, reps: Int? = nil) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
    }
}
