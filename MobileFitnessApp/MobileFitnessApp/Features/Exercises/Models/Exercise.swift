//
//  Exercise.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var muscleGroup: String?
    var isBuiltIn: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \RoutineExercise.exercise)
    var routineUsages: [RoutineExercise] = []

    init(
        name: String,
        muscleGroup: String? = nil,
        isBuiltIn: Bool = false
    ) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.isBuiltIn = isBuiltIn
    }
}
