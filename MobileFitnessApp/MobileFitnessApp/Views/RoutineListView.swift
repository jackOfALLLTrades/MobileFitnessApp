//
//  RoutineListView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

struct RoutineListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Routine.name)
    private var routines: [Routine]

    var body: some View {
        NavigationStack {
            List {
                if routines.isEmpty {
                    ContentUnavailableView(
                        "No Routines Yet",
                        systemImage: "dumbbell",
                        description: Text(
                            "Create a routine to organize your workouts."
                        )
                    )
                } else {
                    ForEach(routines) { routine in
                        NavigationLink {
                            CreateRoutineView(routine: routine)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(routine.name)
                                    .font(.headline)

                                Text("\(routine.exercises.count) exercises")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteRoutine(routine)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Routines")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        CreateRoutineView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func deleteRoutine(_ routine: Routine) {
        modelContext.delete(routine)
    }
}

#Preview {
    RoutineListView()
        .modelContainer(for: [
            Exercise.self,
            Routine.self,
            RoutineExercise.self
        ])
}
