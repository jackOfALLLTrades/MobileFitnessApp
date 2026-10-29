// xcode: set sdk=iOS

//
//  Workout.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import Foundation

struct Workout: Identifiable {
    let id = UUID()
    var name: String
    var exercises: [Exercise]
    var estTime: Int
}
