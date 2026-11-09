//
//  SetColumnHeadings.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct SetColumnHeadings: View {
    @AppStorage(AppPreferences.weightUnitKey)
    private var weightUnit: WorkoutWeightUnit = .pounds

    let style: SetRowStyle
    var exerciseName: String = ""

    var body: some View {
        SetRowLayout(style: style) {
            Text("SET")
        } previous: {
            Text("PREVIOUS")
        } weight: {
            Text(weightUnit == .pounds ? "LBS" : "KG")
        } reps: {
            Text(exerciseName == "Plank" ? "SECS" : "REPS")
        } completion: {
            Spacer()
        }
        .font(style.headingFont.weight(.semibold))
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
    }
}

