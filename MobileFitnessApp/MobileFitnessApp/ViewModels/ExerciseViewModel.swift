//
//  ExerciseViewModel.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import Foundation
import Observation

@Observable
class ExerciseViewModel {
    //A few starter exercises so the app isn't empty (delete this list's contents if you don't want them)
    var exercises: [Exercise] = [
        Exercise(name: "Bench Press", sets: Array(repeating: Set(reps: 8, weight: 135), count: 3), rest: [90, 90, 90]),
        Exercise(name: "Squat", sets: Array(repeating: Set(reps: 5, weight: 185), count: 3), rest: [120, 120, 120]),
        Exercise(name: "Pull-Up", sets: Array(repeating: Set(reps: 8), count: 3), rest: [60, 60, 60])
    ]

    //lets user add exercise
    func addExercise(name: String, sets: Int, reps: Int, weight: Int?) {
        let newSet = Set(reps: reps, weight: weight)
        exercises.append(Exercise(name: name,
                                  sets: Array(repeating: newSet, count: sets),
                                  rest: Array(repeating: 60, count: sets)))
    }

    //delete an exercise
    func deleteExercise(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            exercises.remove(at: index)
        }
    }
}
