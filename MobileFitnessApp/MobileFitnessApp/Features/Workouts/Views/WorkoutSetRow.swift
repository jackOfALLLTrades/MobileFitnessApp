//
//  WorkoutSetRow.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct WorkoutSetRow: View {

    let workoutSet: WorkoutSet
    let previousPerformance: String

    @Binding var weightText: String
    @Binding var repsText: String

    let onToggleCompleted: () -> Void

    var body: some View {
        SetRowLayout(style: .workout) {

            Text("\(workoutSet.order + 1)")
                .font(.subheadline.weight(.medium))
        } previous: {

            Text(previousPerformance)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        } weight: {

            TextField("—", text: $weightText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
        } reps: {
            TextField("—", text: $repsText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
        } completion: {
            Button(action: onToggleCompleted) {
                Image(
                    systemName: workoutSet.isCompleted
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.title2)
                .foregroundStyle(
                    workoutSet.isCompleted ? .green : .secondary
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                workoutSet.isCompleted
                    ? "Mark set incomplete"
                    : "Mark set complete"
            )
        }
        .padding(.vertical, 3)
    }
}
