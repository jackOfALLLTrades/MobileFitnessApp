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
            //Added Calender view -- pending github style
            withWorkoutBanner(CalendarView())
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(3)
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
                minimizedWorkoutBanner(for: session)
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

    // MARK: - Minimized Workout Banner

    private func minimizedWorkoutBanner(
        for session: WorkoutSession
    ) -> some View {
        HStack(spacing: 12) {

            Button {
                selectedTab = 1
                workoutSessionManager.reopenSession()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.up")
                        .font(.headline)
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            Text(
                                elapsedTime(
                                    since: session.startDate,
                                    now: context.date
                                )
                            )
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                showingCancelConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                    .frame(width: 34, height: 34)
                    .background(.quaternary.opacity(0.7))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cancel workout")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .fill(.ultraThinMaterial)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }

    // MARK: - Timer

    private func elapsedTime(
        since startDate: Date,
        now: Date
    ) -> String {
        let totalSeconds = max(
            0,
            Int(now.timeIntervalSince(startDate))
        )

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(
            format: "%02d:%02d:%02d",
            hours,
            minutes,
            seconds
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

        modelContext.delete(session)

        do {
            try modelContext.save()
            workoutSessionManager.clearSession()
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
            SessionExercise.self,
            WorkoutSet.self
        ])
}
