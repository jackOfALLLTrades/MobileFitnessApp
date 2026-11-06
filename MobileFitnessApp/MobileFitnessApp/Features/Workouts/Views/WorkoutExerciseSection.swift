//
//  WorkoutExerciseSection.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI
import SwiftData

struct WorkoutExerciseSection: View {

    let exercise: WorkoutExercise

    let previousPerformance: (Int) -> String

    let weightBinding: (WorkoutSet) -> Binding<String>
    let repsBinding: (WorkoutSet) -> Binding<String>

    let onToggleCompleted: (WorkoutSet) -> Void
    let onRemoveSet: (WorkoutSet) -> Void
    let onAddSet: () -> Void

    let onReorderExercises: () -> Void
    let onReplaceExercise: () -> Void
    let onDeleteExercise: () -> Void

    var body: some View {
        Section {

            HStack {
                Text(exercise.exerciseName)
                    .font(.headline)

                Spacer()

                Menu {
                    Button(action: onReorderExercises) {
                        Label(
                            "Reorder Exercises",
                            systemImage: "arrow.up.arrow.down"
                        )
                    }

                    Button(action: onReplaceExercise) {
                        Label(
                            "Replace Exercise",
                            systemImage: "arrow.left.arrow.right"
                        )
                    }

                    Divider()

                    Button(
                        role: .destructive,
                        action: onDeleteExercise
                    ) {
                        Label(
                            "Delete Exercise",
                            systemImage: "trash"
                        )
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
            }
            .listRowSeparator(.hidden)

            SetColumnHeadings(style: .workout)

            ForEach(
                exercise.sets.sorted { $0.order < $1.order }
            ) { workoutSet in
                WorkoutSetRow(
                    workoutSet: workoutSet,
                    previousPerformance: previousPerformance(
                        workoutSet.order
                    ),
                    weightText: weightBinding(workoutSet),
                    repsText: repsBinding(workoutSet),
                    onToggleCompleted: {
                        onToggleCompleted(workoutSet)
                    }
                )
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: false
                ) {
                    if exercise.sets.count > 1 {
                        Button(role: .destructive) {
                            onRemoveSet(workoutSet)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }

            Button(action: onAddSet) {
                Label("Add Set", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.quaternary.opacity(0.5))
            )
            .listRowSeparator(.hidden)
        }
    }
}
