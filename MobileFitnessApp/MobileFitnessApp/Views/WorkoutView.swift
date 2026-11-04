// xcode: set sdk=iOS

//
//  CreateWorkoutView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import SwiftUI

struct WorkoutView: View {
    @Environment(WorkoutViewModel.self) private var workoutVM
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(workoutVM.workouts) { workout in
                    NavigationLink {
                        WorkoutDetailView(workout: workout)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(workout.name).font(.headline)
                            Text("\(workout.exercises.count) exercises · ~\(workout.estTime) min")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { workoutVM.deleteWorkout(at: $0) }
            }
            .overlay {
                if workoutVM.workouts.isEmpty {
                    ContentUnavailableView("No Workouts", systemImage: "list.clipboard", description: Text("Tap + to build one from your exercises."))
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                Button("Add", systemImage: "plus") { showingAdd = true }
            }
            .sheet(isPresented: $showingAdd) {
                AddWorkoutView()
            }
        }
    }
}

struct AddWorkoutView: View {
    @Environment(ExerciseViewModel.self) private var exerciseVM
    @Environment(WorkoutViewModel.self) private var workoutVM
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var estTime = 45
    @State private var selected: [UUID] = []

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Stepper("Estimated time: \(estTime) min", value: $estTime, in: 5...180, step: 5)

                Section("Exercises") {
                    ForEach(exerciseVM.exercises) { exercise in
                        Button {
                            if let index = selected.firstIndex(of: exercise.id) {
                                selected.remove(at: index)
                            } else {
                                selected.append(exercise.id)
                            }
                        } label: {
                            HStack {
                                Text(exercise.name)
                                Spacer()
                                if selected.contains(exercise.id) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("New Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let chosen = exerciseVM.exercises.filter { selected.contains($0.id) }
                        workoutVM.addWorkout(name: name, estTime: estTime, exercises: chosen)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selected.isEmpty)
                }
            }
        }
    }
}

struct WorkoutDetailView: View {
    @Environment(LogViewModel.self) private var logVM
    @State private var showingLogged = false
    let workout: Workout

    var body: some View {
        List {
            Section {
                Button("Log This Workout") {
                    logVM.logSession(from: workout)
                    showingLogged = true
                }
            }

            ForEach(workout.exercises) { exercise in
                Section(exercise.name) {
                    ForEach(exercise.sets.indices, id: \.self) { index in
                        Text("Set \(index + 1): \(exercise.sets[index].summary)")
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .alert("Workout logged", isPresented: $showingLogged) {
            Button("OK", role: .cancel) { }
        }
    }
}

#Preview {
    WorkoutView()
        .environment(ExerciseViewModel())
        .environment(WorkoutViewModel())
        .environment(LogViewModel())
}
