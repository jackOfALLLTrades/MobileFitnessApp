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
    @State private var muscleGroup: String?
    @State private var loggingMode: ExerciseLoggingMode = .weighted

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

                    Picker("Muscle Group", selection: $muscleGroup) {
                        Text("None").tag(nil as String?)
                        ForEach(ExerciseBrowser.muscleGroupOrder, id: \.self) { group in
                            Text(group).tag(Optional(group))
                        }
                    }

                    Picker("Log", selection: $loggingMode) {
                        ForEach(ExerciseLoggingMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }
                .themeListRow()

                if isDuplicate {
                    Section {
                        Text("This exercise already exists in your library.")
                            .foregroundStyle(.red)
                    }
                }
            }
            .themeBackground()
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
            muscleGroup: muscleGroup,
            loggingMode: loggingMode
        )

        modelContext.insert(exercise)
        dismiss()
    }
}
