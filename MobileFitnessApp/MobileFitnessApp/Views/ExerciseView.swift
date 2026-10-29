//
//  CreateExerciseView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import SwiftUI

struct ExerciseView: View {
    @Environment(ExerciseViewModel.self) private var exerciseVM
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(exerciseVM.exercises) { exercise in
                    NavigationLink(exercise.name) {
                        ExerciseDetailView(exercise: exercise)
                    }
                }
                .onDelete { exerciseVM.deleteExercise(at: $0) }
            }
            .overlay {
                if exerciseVM.exercises.isEmpty {
                    ContentUnavailableView("No Exercises", systemImage: "dumbbell", description: Text("Tap + to add one."))
                }
            }
            .navigationTitle("Exercises")
            .toolbar {
                Button("Add", systemImage: "plus") { showingAdd = true }
            }
            .sheet(isPresented: $showingAdd) {
                AddExerciseView()
            }
        }
    }
}

struct AddExerciseView: View {
    @Environment(ExerciseViewModel.self) private var exerciseVM
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var sets = 3
    @State private var reps = 10
    @State private var weightText = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                Stepper("Reps: \(reps)", value: $reps, in: 1...100)
                TextField("Weight (lb, optional)", text: $weightText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("New Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        exerciseVM.addExercise(name: name, sets: sets, reps: reps, weight: Int(weightText))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct ExerciseDetailView: View {
    @Environment(LogViewModel.self) private var logVM
    let exercise: Exercise

    var body: some View {
        List {
            Section("Your Progress") {
                LabeledContent("Times logged", value: "\(logVM.timesLogged(exercise.name))")
                if let best = logVM.bestWeight(for: exercise.name) {
                    LabeledContent("Best weight", value: "\(best) lb")
                }
            }

            Section("Sets") {
                ForEach(exercise.sets.indices, id: \.self) { index in
                    Text("Set \(index + 1): \(exercise.sets[index].summary)")
                }
            }
        }
        .navigationTitle(exercise.name)
    }
}

#Preview {
    ExerciseView()
        .environment(ExerciseViewModel())
        .environment(LogViewModel())
}
