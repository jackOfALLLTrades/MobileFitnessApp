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

    //Short text for showing a set, like "8 reps @ 135 lb"
    var summary: String {
        var parts: [String] = []
        if let reps { parts.append("\(reps) reps") }
        if let time { parts.append(time) }
        if let weight { parts.append("@ \(weight) lb") }
        return parts.joined(separator: " ")
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var sets: [Set]
    var rest: [Int]
}
