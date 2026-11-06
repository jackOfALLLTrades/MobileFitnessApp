//
//  RoutineExercise.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import Foundation
import SwiftData

/// An exercise placement in a routine, including order and planned set count.
@Model
final class RoutineExercise {
    var exercise: Exercise
    var routine: Routine?

    var order: Int
    var plannedSets: Int

    init(exercise: Exercise, order: Int, plannedSets: Int) {
        self.exercise = exercise
        self.order = order
        self.plannedSets = plannedSets
    }
}
