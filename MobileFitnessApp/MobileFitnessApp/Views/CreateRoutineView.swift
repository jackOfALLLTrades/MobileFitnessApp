//
//  CreateRoutineView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

struct CreateRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let routine: Routine?

    @State private var routineName: String
    @State private var selectedExercises: [Exercise]
    @State private var plannedSets: [PersistentIdentifier: Int]

    init(routine: Routine? = nil) {
        self.routine = routine

        let existingExercises = (routine?.exercises ?? [])
            .sorted { $0.order < $1.order }

        _routineName = State(initialValue: routine?.name ?? "")

        _selectedExercises = State(
            initialValue: existingExercises.map { $0.exercise }
        )

        _plannedSets = State(
            initialValue: Dictionary(
                uniqueKeysWithValues: existingExercises.map {
                    ($0.exercise.persistentModelID, $0.plannedSets)
                }
            )
        )
    }

    private var trimmedName: String {
        routineName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValid: Bool {
        !trimmedName.isEmpty && !selectedExercises.isEmpty
    }

    var body: some View {
        Form {
            Section("Routine Information") {
                TextField("Routine Name", text: $routineName)
            }

            Section {
                NavigationLink {
                    ExerciseSelectionView(
                        selectedExercises: $selectedExercises
                    )
                } label: {
                    Label("Select Exercises", systemImage: "plus")
                }
            }

            if selectedExercises.isEmpty {
                Section("Exercises") {
                    Text("No exercises selected.")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(
                    selectedExercises,
                    id: \.persistentModelID
                ) { exercise in
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            let setCount = plannedSets[
                                exercise.persistentModelID,
                                default: 3
                            ]

                            ForEach(1...setCount, id: \.self) { setNumber in
                                HStack {
                                    Text("Set \(setNumber)")
                                        .foregroundStyle(.primary)

                                    Spacer()
                                }
                            }

                            // Add/remove set controls
                            HStack(spacing: 0) {
                                Button {
                                    addSet(for: exercise)
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.title3.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                Rectangle()
                                    .fill(.quaternary)
                                    .frame(width: 1, height: 24)

                                Button {
                                    removeSet(for: exercise)
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.title3.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .disabled(setCount <= 1)
                            }
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                removeExercise(exercise)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    } header: {
                        Text(exercise.name)
                    }
                }
            }
        }
        .navigationTitle(routine == nil ? "New Routine" : "Edit Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveRoutine()
                }
                .disabled(!isValid)
            }
        }
    }

    private func addSet(for exercise: Exercise) {
        let id = exercise.persistentModelID
        plannedSets[id, default: 3] += 1
    }

    private func removeSet(for exercise: Exercise) {
        let id = exercise.persistentModelID
        let currentCount = plannedSets[id, default: 3]

        if currentCount > 1 {
            plannedSets[id] = currentCount - 1
        }
    }

    private func removeExercise(_ exercise: Exercise) {
        selectedExercises.removeAll {
            $0.persistentModelID == exercise.persistentModelID
        }
    }

    private func saveRoutine() {
        let savedRoutine: Routine

        if let routine {
            savedRoutine = routine
            savedRoutine.name = trimmedName
        } else {
            savedRoutine = Routine(name: trimmedName)
            modelContext.insert(savedRoutine)
        }

        let existingLinks = savedRoutine.exercises

        // Remove exercise associations that are no longer selected.
        for link in existingLinks {
            let isStillSelected = selectedExercises.contains {
                $0.persistentModelID == link.exercise.persistentModelID
            }

            if !isStillSelected {
                modelContext.delete(link)
            }
        }

        // Update existing associations or create new ones.
        for (index, exercise) in selectedExercises.enumerated() {
            if let existingLink = existingLinks.first(where: {
                $0.exercise.persistentModelID == exercise.persistentModelID
            }) {
                existingLink.order = index
                existingLink.plannedSets = plannedSets[
                    exercise.persistentModelID,
                    default: 3
                ]
            } else {
                let newLink = RoutineExercise(
                    exercise: exercise,
                    order: index,
                    plannedSets: plannedSets[
                        exercise.persistentModelID,
                        default: 3
                    ]
                )

                newLink.routine = savedRoutine
                modelContext.insert(newLink)
            }
        }

        dismiss()
    }
}

#Preview {
    NavigationStack {
        CreateRoutineView()
    }
    .modelContainer(for: [
        Exercise.self,
        Routine.self,
        RoutineExercise.self
    ])
}

