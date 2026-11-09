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
        ExerciseDefinition(name: "Push-Up", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Incline Push-Up", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Incline Dumbbell Bench Press", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Dumbbell Fly", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Cable Chest Press", muscleGroup: "Chest"),
        ExerciseDefinition(name: "Banded Chest Press", muscleGroup: "Chest"),

        // Back
        ExerciseDefinition(name: "Barbell Row", muscleGroup: "Back"),
        ExerciseDefinition(name: "Lat Pulldown", muscleGroup: "Back"),
        ExerciseDefinition(name: "Pull-Up", muscleGroup: "Back"),
        ExerciseDefinition(name: "Seated Cable Row", muscleGroup: "Back"),
        ExerciseDefinition(name: "Deadlift", muscleGroup: "Back"),
        ExerciseDefinition(name: "Chin-Up", muscleGroup: "Back"),
        ExerciseDefinition(name: "Inverted Row", muscleGroup: "Back"),
        ExerciseDefinition(name: "Single-Arm Dumbbell Row", muscleGroup: "Back"),
        ExerciseDefinition(name: "Straight-Arm Cable Pulldown", muscleGroup: "Back"),
        ExerciseDefinition(name: "Banded Row", muscleGroup: "Back"),
        ExerciseDefinition(name: "Banded Lat Pulldown", muscleGroup: "Back"),

        // Shoulders
        ExerciseDefinition(name: "Overhead Press", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Lateral Raise", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Front Raise", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Reverse Fly", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Dumbbell Shoulder Press", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Cable Lateral Raise", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Cable Face Pull", muscleGroup: "Shoulders"),
        ExerciseDefinition(name: "Banded Pull-Apart", muscleGroup: "Shoulders"),

        // Biceps
        ExerciseDefinition(name: "Bicep Curl", muscleGroup: "Biceps"),
        ExerciseDefinition(name: "Hammer Curl", muscleGroup: "Biceps"),
        ExerciseDefinition(name: "Preacher Curl", muscleGroup: "Biceps"),
        ExerciseDefinition(name: "Incline Dumbbell Curl", muscleGroup: "Biceps"),
        ExerciseDefinition(name: "Cable Bicep Curl", muscleGroup: "Biceps"),
        ExerciseDefinition(name: "Banded Bicep Curl", muscleGroup: "Biceps"),

        // Triceps
        ExerciseDefinition(name: "Tricep Pushdown", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Skull Crusher", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Overhead Tricep Extension", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Dip", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Close-Grip Push-Up", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Cable Overhead Tricep Extension", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Dumbbell Tricep Kickback", muscleGroup: "Triceps"),
        ExerciseDefinition(name: "Banded Tricep Pushdown", muscleGroup: "Triceps"),

        // Legs
        ExerciseDefinition(name: "Squat", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Leg Press", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Leg Extension", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Leg Curl", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Romanian Deadlift", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Lunge", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Calf Raise", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Bodyweight Squat", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Glute Bridge", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Goblet Squat", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Dumbbell Romanian Deadlift", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Dumbbell Bulgarian Split Squat", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Dumbbell Step-Up", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Cable Pull-Through", muscleGroup: "Legs"),
        ExerciseDefinition(name: "Banded Lateral Walk", muscleGroup: "Legs"),

        // Core
        ExerciseDefinition(name: "Plank", muscleGroup: "Core"),
        ExerciseDefinition(name: "Crunch", muscleGroup: "Core"),
        ExerciseDefinition(name: "Hanging Leg Raise", muscleGroup: "Core"),
        ExerciseDefinition(name: "Reverse Crunch", muscleGroup: "Core"),
        ExerciseDefinition(name: "Lying Leg Raise", muscleGroup: "Core"),
        ExerciseDefinition(name: "Dead Bug", muscleGroup: "Core"),
        ExerciseDefinition(name: "Cable Crunch", muscleGroup: "Core"),
        ExerciseDefinition(name: "Cable Pallof Press", muscleGroup: "Core"),
        ExerciseDefinition(name: "Banded Pallof Press", muscleGroup: "Core")
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
