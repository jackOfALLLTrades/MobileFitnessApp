//
//  WorkoutSetRow.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI
import UIKit

struct WorkoutSetRow: View {
    @Environment(\.colorScheme) private var colorScheme

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

            setInput($weightText, keyboard: .decimalPad)
        } reps: {
            setInput($repsText, keyboard: .numberPad)
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

    @ViewBuilder
    private func setInput(_ text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        let field = TextField("—", text: text)
            .keyboardType(keyboard)
            .multilineTextAlignment(.center)

        if colorScheme == .dark {
            field
                .textFieldStyle(.plain)
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 6))
        } else {
            field.textFieldStyle(.roundedBorder)
        }
    }
}
