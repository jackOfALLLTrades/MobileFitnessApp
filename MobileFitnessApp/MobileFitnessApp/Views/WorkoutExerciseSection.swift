//
//  WorkoutExerciseSection.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI
import SwiftData

struct WorkoutExerciseSection: View {

    let exercise: SessionExercise

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

            // Exercise name and options menu
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

            // Column headings
            HStack(spacing: 8) {
                Text("SET")
                    .frame(width: 30, alignment: .center)
                    .padding(.leading, 4)

                Text("PREVIOUS")
                    .frame(width: 82, alignment: .center)

                Text("LBS")
                    .frame(maxWidth: .infinity)

                Text("REPS")
                    .frame(maxWidth: .infinity)

                Spacer()
                    .frame(width: 28)
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .listRowSeparator(.hidden)

            // Individual set rows
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

            // Add Set
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
