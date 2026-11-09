//
//  ExerciseProgressView.swift
//  MobileFitnessApp
//
//  Created by Zaynab Tabassi on 11/8/26.
//

import SwiftUI
import SwiftData
import Charts

struct ExerciseProgressView: View {
    
    @Query(
        filter: #Predicate<WorkoutSession> { $0.isCompleted == true },
        sort: \WorkoutSession.startDate
    )
    
    private var sessions: [WorkoutSession]
    
    @State private var selectedExercise = ""
    
    private let calculator = ExerciseProgressCalculator()
    
    private var exerciseNames: [String] {
        calculator.loggedExerciseNames(in: sessions)
    }
    
    private var points: [ExerciseProgressPoints] {
        calculator.points(for: selectedExercise, in: sessions)
    }
    
    private var personalRecord: Double? {
        points.map(\.topWeight).max()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if exerciseNames.isEmpty {
                Text("Finish a workout with weighted sets to see your progress.")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Exercise", selection: $selectedExercise) {
                    ForEach(exerciseNames, id: \.self) { name in
                        Text(name).tag(name)
                    }
                }
                .pickerStyle(.menu)
                
                if let personalRecord {
                    Text("PR: \(WorkoutWeightFormatter.string(from: personalRecord)) lb")
                        .font(.headline)
                }
                
                Chart(points) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.topWeight)
                    )
                }
                .chartYAxisLabel("lbs")
                .frame(height: 220)
            }
        }
        .padding(.vertical, 8)
        .onAppear(perform: selectFirstExerciseIfNeeded)
        .onChange(of: exerciseNames) { _, _ in
            selectFirstExerciseIfNeeded()
        }
    }
    
    private func selectFirstExerciseIfNeeded() {
        if !exerciseNames.contains(selectedExercise) {
            selectedExercise = exerciseNames.first ?? ""
        }
    }
}
