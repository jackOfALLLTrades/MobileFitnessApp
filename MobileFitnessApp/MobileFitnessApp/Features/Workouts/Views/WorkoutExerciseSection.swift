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

    let previousNote: String?
    let noteBinding: (UUID) -> Binding<String>
    let onAddNote: () -> Void
    let onRemoveNote: (UUID) -> Void

    @FocusState private var focusedNote: UUID?

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

                Button(action: onAddNote) {
                    Image(systemName: "note.text.badge.plus")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Add exercise note")

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
            .themeListRow()

            ForEach(exercise.visibleNotes) { note in
                let showHint = note.id == exercise.visibleNotes.first?.id && focusedNote != note.id

                HStack(alignment: .top) {
                    Image(systemName: "note.text")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)

                    TextField(
                        "Exercise notes",
                        text: noteBinding(note.id),
                        prompt: Text(showHint ? (previousNote ?? "") : "")
                            .foregroundColor(.secondary),
                        axis: .vertical
                    )
                    .focused($focusedNote, equals: note.id)
                }
                .font(.subheadline)
                .listRowSeparator(.hidden)
                .themeListRow()
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        if focusedNote == note.id { focusedNote = nil }
                        onRemoveNote(note.id)
                    } label: {
                        Label("Remove Note", systemImage: "trash")
                    }
                }
            }

            SetColumnHeadings(style: .workout, loggingMode: exercise.loggingMode)
                .themeListRow()

            ForEach(
                exercise.sets.sorted { $0.order < $1.order }
            ) { workoutSet in
                WorkoutSetRow(
                    workoutSet: workoutSet,
                    loggingMode: exercise.loggingMode,
                    previousPerformance: previousPerformance(
                        workoutSet.order
                    ),
                    weightText: weightBinding(workoutSet),
                    repsText: repsBinding(workoutSet),
                    onToggleCompleted: {
                        onToggleCompleted(workoutSet)
                    }
                )
                .themeListRow()
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
            .themeListRow()
        }
    }
}
