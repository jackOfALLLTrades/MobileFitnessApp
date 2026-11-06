//
//  WorkoutWeightFormatter.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation

/// Removes the redundant decimal from whole weights without truncating fractional loads.
enum WorkoutWeightFormatter {
    static func string(from weight: Double) -> String {
        let text = String(weight)
        return text.hasSuffix(".0") ? String(text.dropLast(2)) : text
    }
}
