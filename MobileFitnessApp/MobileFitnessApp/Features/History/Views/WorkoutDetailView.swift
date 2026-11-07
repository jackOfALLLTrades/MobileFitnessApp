//
//  WorkoutDetailView.swift
//  MobileFitnessApp
//
//  Created by Zaynab Tabassi on 11/7/26.
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let session: WorkoutSession
    
    private var exercises: [WorkoutExercise] {
        session.exercises
            .sorted {$0.order < $1.order }
            .filter { !completedSets(for: $0).isEmpty }
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent(
                    "Date",
                    value: session.startDate.formatted(date: .long, time: .shortened)
                )
                
                if let endDate = session.endDate {
                    LabeledContent(
                        "Duration",
                        value: WorkoutDurationFormatter.string(since: session.startDate, now: endDate)
                    )
                }
            }
            
            if exercises.isEmpty {
                Section {
                    Text("No sets were checked off in this workout.")
                        .foregroundStyle(.secondary)
                }
            }
            
            ForEach(exercises) { exercise in
                Section(exercise.exerciseName) {
                    ForEach(
                        Array(completedSets(for: exercise).enumerated()),
                        id: \.element.persistentModelID
                    ) { index, workoutSet in
                        HStack {
                            Text("Set \(index + 1)")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(setText(workoutSet, for: exercise))
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .navigationTitle(session.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func completedSets(for exercise: WorkoutExercise) -> [WorkoutSet] {
        exercise.sets
            .filter(\.isCompleted)
            .sorted { $0.order < $1.order }
    }
    
    private func setText(_ workoutSet: WorkoutSet, for exercise: WorkoutExercise) -> String {
        let reps = workoutSet.reps.map(String.init) ?? "-"
        
        if exercise.exerciseName == "Plank" {
            return "\(reps) sec"
        }
        
        let weight = workoutSet.weight.map { WorkoutWeightFormatter.string(from: $0) } ?? "-"
        return "\(weight) lb x \(reps)"
    }
}

