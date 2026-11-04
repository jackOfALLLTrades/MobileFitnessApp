// xcode: set sdk=iOS

//
//  Session.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import Foundation

//A session is a logged instance of a workout, or a group of exercises
struct Session: Identifiable {
    let id = UUID()
    var date: Date
    var name: String
    var workout: Workout?
    var exercises: [Exercise]?

    //Total weight lifted: reps x weight, summed over every set
    var volume: Int {
        (exercises ?? []).reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { $0 + ($1.reps ?? 0) * ($1.weight ?? 0) }
        }
    }
}
