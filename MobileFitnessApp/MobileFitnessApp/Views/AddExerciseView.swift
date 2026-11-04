//
//  AddExerciseView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var exercises: [Exercise]

    @State private var name = ""
    @State private var muscleGroup = ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isDuplicate: Bool {
        exercises.contains {
            $0.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }

    private var isValid: Bool {
        !trimmedName.isEmpty && !isDuplicate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Information") {
                    TextField("Exercise Name", text: $name)

                    TextField("Muscle Group (Optional)", text: $muscleGroup)
                }

                if isDuplicate {
                    Section {
                        Text("This exercise already exists in your library.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExercise()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func saveExercise() {
        let exercise = Exercise(
            name: trimmedName,
            muscleGroup: muscleGroup.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty ? nil : muscleGroup.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        )

        modelContext.insert(exercise)
        dismiss()
    }
}
