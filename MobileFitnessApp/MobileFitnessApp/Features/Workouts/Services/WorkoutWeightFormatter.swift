//
//  WorkoutWeightFormatter.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation

enum WorkoutWeightUnit: String, CaseIterable {
    case pounds = "lb"
    case kilograms = "kg"

    private static let kilogramsPerPound = 0.45359237

    var title: String {
        switch self {
        case .pounds: "Pounds (lb)"
        case .kilograms: "Kilograms (kg)"
        }
    }

    func displayedWeight(fromPounds pounds: Double) -> Double {
        self == .kilograms ? pounds * Self.kilogramsPerPound : pounds
    }

    func storedPounds(from weight: Double) -> Double {
        self == .kilograms ? weight / Self.kilogramsPerPound : weight
    }
}

enum WorkoutWeightFormatter {
    static func string(from pounds: Double, unit: WorkoutWeightUnit = .pounds) -> String {
        unit.displayedWeight(fromPounds: pounds).formatted(
            .number.precision(.fractionLength(0...2)).grouping(.never)
        )
    }
}
