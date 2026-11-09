//
//  WorkoutHistoryView.swift
//  MobileFitnessApp
//
//  Created by Zaynab Tabassi on 11/6/26.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Query(
        filter: #Predicate<WorkoutSession> { $0.isCompleted == true },
        sort: \WorkoutSession.startDate,
        order: .reverse
    )
    private var sessions: [WorkoutSession]
    
    var body: some View {
        NavigationStack {
            List {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Finished workouts will show up here.")
                    )
                } else {
                    ForEach(sessions) { session in
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
                    } .navigationTitle("History")
                }
            }
        }
    }
}
