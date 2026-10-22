//
//  HomeView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import SwiftUI

struct HomeView: View {
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
    }
}

#Preview {
    HomeView()
}
