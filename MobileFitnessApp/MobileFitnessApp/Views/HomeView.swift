// xcode: set sdk=iOS

//
//  HomeView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import SwiftUI

struct HomeView: View {
    //One shared copy of each view model, passed down to every tab
    @State private var exerciseVM = ExerciseViewModel()
    @State private var workoutVM = WorkoutViewModel()
    @State private var logVM = LogViewModel()

    var body: some View {
        TabView {
            
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ExerciseView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell")
                }
            
            WorkoutView()
                .tabItem {
                    Label("Workouts", systemImage: "list.clipboard")
                }
            
            LogView()
                .tabItem {
                    Label("Log", systemImage: "calendar")
                }
        }
        .environment(exerciseVM)
        .environment(workoutVM)
        .environment(logVM)
    }
}

#Preview {
    HomeView()
}
