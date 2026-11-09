//
//  ExerciseCatalog.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import Foundation
import SwiftData

struct ExerciseDefinition {
    let name: String
    let muscleGroup: String
}

enum ExerciseCatalog {

    static let builtInExercises: [ExerciseDefinition] = [

        // Chest
        ExerciseDefinition(name: "Bench Press", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Incline Bench Press", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Dumbbell Bench Press", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Chest Fly", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Cable Crossover", muscleGroup: "Chest"),

        // Back
        ExerciseDefinition(name: "Barbell Row", muscleGroup: "Back"),
        ExerciseDefinition(name: "Lat Pulldown", muscleGroup: "Back"),
        ExerciseDefinition(name: "Pull-Up", muscleGroup: "Back"),
        ExerciseDefinition(name: "Seated Cable Row", muscleGroup: "Back"),
        ExerciseDefinition(name: "Deadlift", muscleGroup: "Back"),

        // Shoulders
        ExerciseDefinition(name: "Overhead Press", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Lateral Raise", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Front Raise", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Reverse Fly", muscleGroup: "Shoulders"),

        // Biceps
        ExerciseDefinition(name: "Bicep Curl", muscleGroup: "Biceps"),
        ExerciseDefinition(name: "Hammer Curl", muscleGroup: "Biceps"),
        ExerciseDefinition(name: "Preacher Curl", muscleGroup: "Biceps"),

        // Triceps
        ExerciseDefinition(name: "Tricep Pushdown", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Skull Crusher", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Overhead Tricep Extension", muscleGroup: "Triceps"),

        // Legs
        ExerciseDefinition(name: "Squat", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Leg Press", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Leg Extension", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Leg Curl", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Romanian Deadlift", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Lunge", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Calf Raise", muscleGroup: "Legs"),

        // Core
        ExerciseDefinition(name: "Plank", muscleGroup: "Core"),
        ExerciseDefinition(name: "Crunch", muscleGroup: "Core"),
        ExerciseDefinition(name: "Hanging Leg Raise", muscleGroup: "Core"),
        ExerciseDefinition(name: "Russian Twist", muscleGroup: "Core"),
        ExerciseDefinition(name: "Dead Bug", muscleGroup: "Core"),
        ExerciseDefinition(name: "Side Plank", muscleGroup: "Core")

    ]

    static func seed(into context: ModelContext) {
        do {
            let existingExercises = try context.fetch(
                FetchDescriptor<Exercise>()
            )

            for definition in builtInExercises {
                let normalizedName = definition.name
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()

                if let existingExercise = existingExercises.first(where: {
                    $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        .lowercased() == normalizedName
                }) {
                    // Recognize an existing matching exercise as built-in.
                    existingExercise.isBuiltIn = true
                    existingExercise.muscleGroup = definition.muscleGroup
                } else {
                    // Insert the built-in exercise if it doesn't exist.
                    let exercise = Exercise(
                        name: definition.name,
                        muscleGroup: definition.muscleGroup,
                        isBuiltIn: true
                    )

                    context.insert(exercise)
                }
            }

            try context.save()

        } catch {
            print("Failed to seed exercise catalog: \(error)")
        }
    }

}
