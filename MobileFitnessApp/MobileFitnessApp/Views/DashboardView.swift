//
//  DashboardView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import SwiftUI

struct DashboardView: View {
    @Environment(WorkoutViewModel.self) private var workoutVM
    @Environment(LogViewModel.self) private var logVM

    var body: some View {
        NavigationStack {
            List {
                Section("Progress") {
                    LabeledContent("Workouts this week", value: "\(logVM.sessionsThisWeek)")
                    LabeledContent("Current streak", value: "\(logVM.currentStreak) days")
                    LabeledContent("Total sessions", value: "\(logVM.sessions.count)")
                    LabeledContent("Total volume", value: "\(logVM.totalVolume.formatted()) lb")
                }

                Section("Last Workout") {
                    if let last = logVM.sessions.first {
                        NavigationLink {
                            SessionDetailView(session: last)
                        } label: {
                            LabeledContent(last.name, value: last.date.formatted(date: .abbreviated, time: .omitted))
                        }
                    } else {
                        Text("Nothing logged yet")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Quick Log") {
                    if workoutVM.workouts.isEmpty {
                        Text("Create a workout in the Workouts tab to log it here")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(workoutVM.workouts) { workout in
                        Button("Log \(workout.name)") {
                            logVM.logSession(from: workout)
                        }
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    DashboardView()
        .environment(WorkoutViewModel())
        .environment(LogViewModel())
}
