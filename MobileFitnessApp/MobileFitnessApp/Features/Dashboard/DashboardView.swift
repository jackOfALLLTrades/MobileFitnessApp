//
//  DashboardView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            WorkoutCalendarView()
                .navigationTitle("Home")
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [
            Exercise.self,
            Routine.self,
            RoutineExercise.self,
            WorkoutSession.self,
            WorkoutExercise.self,
            WorkoutSet.self
        ], inMemory: true)
}
