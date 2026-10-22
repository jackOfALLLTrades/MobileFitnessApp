//
//  Session.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import Foundation

//A session is a logged instance of a workout, or a group of exercises
struct Session {
    var date: Date
    var name: String
    var workout: Workout?
    var exercises: [Exercise]?
}
