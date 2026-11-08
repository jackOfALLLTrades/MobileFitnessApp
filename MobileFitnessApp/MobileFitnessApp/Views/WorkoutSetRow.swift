//
//  WorkoutSetRow.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI
import SwiftData

struct WorkoutSetRow: View {

    let workoutSet: WorkoutSet
    let previousPerformance: String

    @Binding var weightText: String
    @Binding var repsText: String

    let onToggleCompleted: () -> Void

    var body: some View {
        HStack(spacing: 8) {

            Text("\(workoutSet.order + 1)")
                .font(.subheadline.weight(.medium))
                .frame(width: 30, alignment: .center)
                .padding(.leading, 4)

            Text(previousPerformance)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: 82, alignment: .center)

            TextField("—", text: $weightText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            TextField("—", text: $repsText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

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
            .frame(width: 28)
            .accessibilityLabel(
                workoutSet.isCompleted
                    ? "Mark set incomplete"
                    : "Mark set complete"
            )
        }
        .padding(.vertical, 3)
    }
}
