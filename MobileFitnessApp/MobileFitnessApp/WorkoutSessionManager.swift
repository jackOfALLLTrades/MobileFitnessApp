//
//  WorkoutSessionManager.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class WorkoutSessionManager: ObservableObject {

    @Published var activeSession: WorkoutSession?
    @Published var isMinimized = false

    // Starts tracking a newly created workout.
    func beginSession(_ session: WorkoutSession) {
        activeSession = session
        isMinimized = false
    }

    // Minimizes the active workout.
    func minimizeSession() {
        guard activeSession != nil else { return }
        isMinimized = true
    }

    // Reopens a minimized workout.
    func reopenSession() {
        guard activeSession != nil else { return }
        isMinimized = false
    }

    // Clears the active workout after finishing or discarding it.
    func clearSession() {
        activeSession = nil
        isMinimized = false
    }

    // Restores an unfinished workout when the app launches.
    func restoreActiveSession(
        from modelContext: ModelContext
    ) throws {
        guard activeSession == nil else { return }

        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate {
                $0.isCompleted == false
            },
            sortBy: [
                SortDescriptor(
                    \WorkoutSession.startDate,
                    order: .reverse
                )
            ]
        )

        let unfinishedSessions = try modelContext.fetch(descriptor)

        if let session = unfinishedSessions.first {
            activeSession = session
            isMinimized = true
        }
    }
}
