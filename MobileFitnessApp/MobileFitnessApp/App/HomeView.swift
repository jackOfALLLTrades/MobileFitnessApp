//
//  HomeView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {

    @EnvironmentObject private var workoutSessionManager: WorkoutSessionManager
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab = 0
    @State private var showingCancelConfirmation = false

    var body: some View {
        TabView(selection: $selectedTab) {

            withWorkoutBanner(DashboardView())
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            withWorkoutBanner(RoutineListView())
                .tabItem {
                    Label("Workout", systemImage: "dumbbell")
                }
                .tag(1)

            withWorkoutBanner(
                NavigationStack {
                    Text("Your workout history will appear here.")
                        .foregroundStyle(.secondary)
                        .navigationTitle("Profile")
                }
            )
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(2)
        }
        .fullScreenCover(isPresented: activeWorkoutPresentation) {
            if let session = workoutSessionManager.activeSession {
                NavigationStack {
                    ActiveWorkoutView(session: session)
                }
            }
        }
        .confirmationDialog(
            "Cancel Workout?",
            isPresented: $showingCancelConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancel Workout", role: .destructive) {
                cancelWorkout()
            }

            Button("Keep Workout", role: .cancel) {}
        } message: {
            Text(
                "This will permanently discard your current workout. " +
                "Your logged sets will not be saved to workout history."
            )
        }
        .task {
            restoreActiveSession()
        }
    }

    // MARK: - Tab Banner Layout

    private func withWorkoutBanner<Content: View>(
        _ content: Content
    ) -> some View {
        content.safeAreaInset(edge: .bottom, spacing: 0) {
            if let session = workoutSessionManager.activeSession,
               workoutSessionManager.isMinimized {
                MinimizedWorkoutBanner(
                    session: session,
                    onReopen: {
                        selectedTab = 1
                        workoutSessionManager.reopenSession()
                    },
                    onDiscard: { showingCancelConfirmation = true }
                )
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
            }
        }
    }

    // MARK: - Workout Presentation

    private var activeWorkoutPresentation: Binding<Bool> {
        Binding(
            get: {
                workoutSessionManager.activeSession != nil &&
                !workoutSessionManager.isMinimized
            },
            set: { isPresented in
                if !isPresented {
                    workoutSessionManager.minimizeSession()
                }
            }
        )
    }

    // MARK: - Session Management

    private func restoreActiveSession() {
        do {
            try workoutSessionManager.restoreActiveSession(
                from: modelContext
            )
        } catch {
            print("Failed to restore active workout: \(error)")
        }
    }

    private func cancelWorkout() {
        guard let session = workoutSessionManager.activeSession else {
            return
        }

        do {
            try workoutSessionManager.discardWorkout(session, in: modelContext)
        } catch {
            print("Failed to cancel workout: \(error)")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutSessionManager())
        .modelContainer(for: [
            Exercise.self,
            Routine.self,
            RoutineExercise.self,
            WorkoutSession.self,
            WorkoutExercise.self,
            WorkoutSet.self
        ])
}
