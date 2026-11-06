//
//  MobileFitnessAppApp.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//

import SwiftUI
import SwiftData

@main
struct MobileFitnessAppApp: App {

    @StateObject private var workoutSessionManager =
        WorkoutSessionManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(workoutSessionManager)
        }
        .modelContainer(for: [
            Exercise.self,
            Routine.self,
            RoutineExercise.self,
            WorkoutSession.self,
            WorkoutExercise.self,
            WorkoutSet.self
        ])
    }
}
