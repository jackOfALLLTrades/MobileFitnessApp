//
//  WorkoutHistoryView.swift
//  MobileFitnessApp
//
//  Created by Zaynab Tabassi on 11/6/26.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    enum Display {
        case profile
        case fullHistory
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [WorkoutSession]
    @State private var workoutToDelete: WorkoutSession?
    @State private var showingDeleteConfirmation = false
    @State private var showingDeleteError = false

    @AppStorage(AppPreferences.historyPreviewCountKey)
    private var savedPreviewCount = AppPreferences.defaultHistoryPreviewCount

    private var previewCount: Int {
        AppPreferences.historyPreviewCounts.contains(savedPreviewCount)
            ? savedPreviewCount : AppPreferences.defaultHistoryPreviewCount
    }

    private let display: Display

    init(display: Display = .fullHistory) {
        self.display = display

        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted },
            sortBy: [SortDescriptor(\WorkoutSession.startDate, order: .reverse)]
        )
        if display == .profile {
            descriptor.fetchLimit = AppPreferences.defaultHistoryPreviewCount + 1
        }
        _sessions = Query(descriptor)
    }

    // MARK: - Content

    var body: some View {
        if display == .profile {
            NavigationStack {
                historyList
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                SettingsView()
                            } label: {
                                Label("Settings", systemImage: "gearshape")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
            }
        } else {
            historyList
        }
    }

    private var historyList: some View {
        List {
            if display == .profile {
                Section("History") {
                    workoutRows(Array(sessions.prefix(previewCount)))

                    if sessions.count > previewCount {
                        NavigationLink("View All Workouts") {
                            WorkoutHistoryView(display: .fullHistory)
                        }
                    }
                }
            } else {
                workoutRows(sessions)
            }
        }
        .navigationTitle(display == .profile ? "Profile" : "History")
        .confirmationDialog(
            "Delete Workout?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible,
            presenting: workoutToDelete
        ) { session in
            Button("Delete Workout", role: .destructive) {
                deleteWorkout(session)
            }
            Button("Cancel", role: .cancel) {
                workoutToDelete = nil
            }
        } message: { session in
            Text("Delete the \(session.name) workout from \(session.startDate.formatted(date: .abbreviated, time: .shortened))? Its logged sets and notes will also be deleted.")
        }
        .alert("Couldn’t Delete Workout", isPresented: $showingDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again.")
        }
    }

    // MARK: - Workout Rows

    @ViewBuilder
    private func workoutRows(_ workouts: [WorkoutSession]) -> some View {
        if workouts.isEmpty {
            ContentUnavailableView(
                "No Workouts Yet",
                systemImage: "clock.arrow.circlepath",
                description: Text("Finished workouts will show up here.")
            )
        } else {
            ForEach(workouts) { session in
                NavigationLink {
                    WorkoutDetailView(session: session)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.name)
                            .font(.headline)

                        Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("\(session.exercises.count) exercises")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // Reserve the destructive role for confirmation so the row stays visible.
                    Button {
                        workoutToDelete = session
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
    }

    // MARK: - Deletion

    private func deleteWorkout(_ session: WorkoutSession) {
        defer { workoutToDelete = nil }
        do {
            try WorkoutSessionService(modelContext: modelContext).discardSession(session)
        } catch {
            modelContext.rollback()
            showingDeleteError = true
        }
    }
}
