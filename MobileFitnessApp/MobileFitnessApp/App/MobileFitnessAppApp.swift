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

    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light

    @StateObject private var workoutSessionManager =
        WorkoutSessionManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(workoutSessionManager)
                .tint(theme.accent)
                .preferredColorScheme(theme.colorScheme)
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
