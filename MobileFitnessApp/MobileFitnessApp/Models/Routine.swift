//
//  Routine.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import Foundation
import SwiftData

@Model
final class Routine {
    var name: String

    @Relationship(deleteRule: .cascade, inverse: \RoutineExercise.routine)
    var exercises: [RoutineExercise] = []

    init(name: String) {
        self.name = name
    }
}
