//
//  WorkoutSession.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import Foundation
import SwiftData

/// One workout attempt; active and completed workouts use the same model.
@Model
final class WorkoutSession {
    var name: String
    var startDate: Date
    var endDate: Date?
    var isCompleted: Bool

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.session)
    var exercises: [WorkoutExercise] = []

    init(name: String, startDate: Date = Date()) {
        self.name = name
        self.startDate = startDate
        self.isCompleted = false
    }
}
