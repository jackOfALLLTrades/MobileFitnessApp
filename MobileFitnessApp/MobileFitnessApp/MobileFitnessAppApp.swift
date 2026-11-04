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

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [
            Exercise.self,
            Routine.self,
            RoutineExercise.self,
            WorkoutSession.self,
            SessionExercise.self,
            WorkoutSet.self
        ])
    }
}
