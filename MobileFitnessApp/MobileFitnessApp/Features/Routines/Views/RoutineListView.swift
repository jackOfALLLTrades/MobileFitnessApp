//
//  RoutineListView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

struct RoutineListView: View {

    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var workoutSessionManager:
        WorkoutSessionManager

    @Query(sort: [
        SortDescriptor(\Routine.sortOrder),
        SortDescriptor(\Routine.name)
    ])
    private var routines: [Routine]

    // MARK: - Presentation State

    @State private var routineToEdit: Routine?

    // MARK: - Content

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

                        RoutineCardView(
                            routine: routine,
                            canStart: workoutSessionManager.activeSession == nil,
                            onEdit: { routineToEdit = routine },
                            onDelete: { deleteRoutine(routine) },
                            onStart: { startWorkout(from: routine) }
                        )
                        .themeListRow()
                    }
                    .onMove(perform: moveRoutines)
                }
            }
            .themeBackground()
            .navigationTitle("Routines")
            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    NavigationLink {
                        RoutineEditorView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $routineToEdit) { routine in

                NavigationStack {
                    RoutineEditorView(routine: routine)
                }
            }
        }
    }

    // MARK: - Routine Management

    private func deleteRoutine(_ routine: Routine) {

        modelContext.delete(routine)
        saveChanges()
    }

    private func moveRoutines(
        from source: IndexSet,
        to destination: Int
    ) {

        var reorderedRoutines = routines

        reorderedRoutines.move(
            fromOffsets: source,
            toOffset: destination
        )

        for (index, routine) in reorderedRoutines.enumerated() {
            routine.sortOrder = index
        }

        saveChanges()
    }

    // MARK: - Start Workout

    private func startWorkout(from routine: Routine) {

        guard workoutSessionManager.activeSession == nil else {
            return
        }

        do {
            try workoutSessionManager.startWorkout(from: routine, in: modelContext)
        } catch {
            print("Failed to start workout: \(error)")
        }
    }

    // MARK: - Saving

    private func saveChanges() {

        do {
            try modelContext.save()
        } catch {
            print("Failed to save routines: \(error)")
        }
    }
}

#Preview {
    RoutineListView()
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
