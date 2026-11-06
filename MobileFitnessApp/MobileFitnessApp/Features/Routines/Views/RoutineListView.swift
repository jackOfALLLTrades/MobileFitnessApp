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

    @EnvironmentObject private var workoutSessionManager:
        WorkoutSessionManager

    @Query(sort: [
        SortDescriptor(\Routine.sortOrder),
        SortDescriptor(\Routine.name)
    ])
    private var routines: [Routine]

    @State private var routineToEdit: Routine?

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

                        VStack(alignment: .leading, spacing: 12) {

                            HStack(alignment: .top) {

                                VStack(alignment: .leading, spacing: 4) {

                                    Text(routine.name)
                                        .font(.headline)

                                    Text("\(routine.exercises.count) exercises")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Menu {

                                    Button {
                                        routineToEdit = routine
                                    } label: {
                                        Label(
                                            "Edit Routine",
                                            systemImage: "pencil"
                                        )
                                    }

                                    Button(role: .destructive) {
                                        deleteRoutine(routine)
                                    } label: {
                                        Label(
                                            "Delete Routine",
                                            systemImage: "trash"
                                        )
                                    }

                                } label: {

                                    Image(systemName: "ellipsis")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 36, height: 36)
                                        .contentShape(Rectangle())
                                }
                            }

                            Button {
                                startWorkout(from: routine)
                            } label: {
                                Label("Start Routine", systemImage: "play.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.quaternary.opacity(0.5))
                            )
                            .disabled(workoutSessionManager.activeSession != nil)
                        }
                        .padding(.vertical, 8)
                    }
                    .onMove(perform: moveRoutines)
                }
            }
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

        let session = WorkoutSession(name: routine.name)

        modelContext.insert(session)

        let orderedExercises = routine.exercises.sorted {
            $0.order < $1.order
        }

        for (exerciseIndex, routineExercise) in orderedExercises.enumerated() {

            let workoutExercise = WorkoutExercise(
                exerciseName: routineExercise.exercise.name,
                order: exerciseIndex
            )

            workoutExercise.session = session
            modelContext.insert(workoutExercise)

            let plannedSetCount = max(1, routineExercise.plannedSets)

            for setIndex in 0..<plannedSetCount {

                let workoutSet = WorkoutSet(order: setIndex)
                workoutSet.workoutExercise = workoutExercise

                modelContext.insert(workoutSet)
            }
        }

        do {

            try modelContext.save()

            workoutSessionManager.beginSession(session)

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
