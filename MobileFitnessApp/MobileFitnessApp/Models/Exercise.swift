//
//  Exercise.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import Foundation

//A set can be rep based, or time based
struct Set {
    var reps: Int?
    var time: String?
    var weight: Int?
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var sets: [Set]
    var rest: [Int]
}
