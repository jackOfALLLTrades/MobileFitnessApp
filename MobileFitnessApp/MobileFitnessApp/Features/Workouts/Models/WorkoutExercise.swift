//
//  WorkoutExercise.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    var exerciseName: String
    var order: Int
    var session: WorkoutSession?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workoutExercise)
    var sets: [WorkoutSet] = []

    init(exerciseName: String, order: Int) {
        self.exerciseName = exerciseName
        self.order = order
    }
}
