//
//  ExerciseProgressCalculator.swift
//  MobileFitnessApp
//
//  Created by Zaynab Tabassi on 11/8/26.
//

import Foundation

struct ExerciseProgressPoints: Identifiable {
    
    let id = UUID()
    let date: Date
    let topWeight: Double
}

struct ExerciseProgressCalculator {
    
    func loggedExerciseNames(in sessions: [WorkoutSession]) -> [String] {
        var names = Set<String>()
        
        for session in sessions where session.isCompleted {
            for exercise in session.exercises {
                let hasWeightedSet = exercise.sets.contains {
                    $0.isCompleted && ($0.weight ?? 0) > 0
                }
                if hasWeightedSet {
                    names.insert(exercise.exerciseName)
                }
            }
        }
        return names.sorted()
    }
    
    func points(for exerciseName: String, in sessions: [WorkoutSession]) -> [ExerciseProgressPoints] {
        var result: [ExerciseProgressPoints] = []
        
        for session in sessions where session.isCompleted {
            let weights = session.exercises
                .filter { $0.exerciseName == exerciseName }
                .flatMap { $0.sets }
                .filter { $0.isCompleted }
                .compactMap { $0.weight }
            
            if let top = weights.max(), top > 0 {
                result.append(ExerciseProgressPoints(date: session.startDate, topWeight: top))
            }
        }
        return result.sorted { $0.date < $1.date }
    }
}
