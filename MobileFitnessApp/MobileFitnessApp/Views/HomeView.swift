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

            RoutineListView()
                .tabItem {
                    Label("Workout", systemImage: "dumbbell")
                }

            NavigationStack {
                Text("Your workout history will appear here.")
                    .foregroundStyle(.secondary)
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}

#Preview {
    HomeView()
}
