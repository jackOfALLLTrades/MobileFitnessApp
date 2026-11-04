//
//  WorkoutViewModel.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import Foundation
import Observation

@Observable
class WorkoutViewModel {
    var workouts: [Workout] = []

    //lets user add workout
    func addWorkout(name: String, estTime: Int, exercises: [Exercise]) {
        workouts.append(Workout(name: name, exercises: exercises, estTime: estTime))
    }

    //delete a workout
    func deleteWorkout(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            workouts.remove(at: index)
        }
    }
}
