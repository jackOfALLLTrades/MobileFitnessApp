//
//  ReorderExercisesView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct ReorderExercisesView<Item: Identifiable>: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var exercises: [Item]

    let exerciseName: (Item) -> String

    var body: some View {
        List {
            ForEach(exercises) { exercise in
                Text(exerciseName(exercise))
                    .padding(.vertical, 6)
            }
            .onMove(perform: moveExercises)
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Reorder Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func moveExercises(
        from source: IndexSet,
        to destination: Int
    ) {
        exercises.move(
            fromOffsets: source,
            toOffset: destination
        )
    }
}
