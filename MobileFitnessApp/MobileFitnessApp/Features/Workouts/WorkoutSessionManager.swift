//
//  WorkoutSessionManager.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class WorkoutSessionManager: ObservableObject {

    @Published private(set) var activeSession: WorkoutSession?
    @Published private(set) var isMinimized = false

    // Update app state only after the corresponding persistence operation succeeds.
    func startWorkout(from routine: Routine, in modelContext: ModelContext) throws {
        guard activeSession == nil else { return }
        let session = try WorkoutSessionService(modelContext: modelContext)
            .createSession(from: routine)
        activeSession = session
        isMinimized = false
    }

    func finishWorkout(_ session: WorkoutSession, in modelContext: ModelContext) throws {
        try WorkoutSessionService(modelContext: modelContext).finishSession(session)
        clearSession()
    }

    func discardWorkout(_ session: WorkoutSession, in modelContext: ModelContext) throws {
        try WorkoutSessionService(modelContext: modelContext).discardSession(session)
        clearSession()
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
    private func clearSession() {
        activeSession = nil
        isMinimized = false
    }

    // Restores an unfinished workout when the app launches.
    func restoreActiveSession(
        from modelContext: ModelContext
    ) throws {
        guard activeSession == nil else { return }

        if let session = try WorkoutSessionService(modelContext: modelContext)
            .latestUnfinishedSession() {
            activeSession = session
            isMinimized = true
        }
    }
}
