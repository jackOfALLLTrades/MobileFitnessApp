//
//  ExerciseSelectionRow.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct ExerciseSelectionRow: View {
    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light

    let exercise: Exercise
    let isSelected: Bool
    let showsMuscleGroup: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(exercise.name)
                        .foregroundStyle(.primary)

                    if !exercise.isBuiltIn {
                        Text("Custom")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(.quaternary)
                            .clipShape(Capsule())
                    }
                }

                if showsMuscleGroup,
                   let muscleGroup = exercise.muscleGroup,
                   !muscleGroup.isEmpty {
                    Text(muscleGroup)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? theme.accent : Color.secondary)
        }
        .contentShape(Rectangle())
    }
}
