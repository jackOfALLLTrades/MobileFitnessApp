//
//  ExerciseLibraryView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/4/26.
//

import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Exercise.name)
    private var exercises: [Exercise]

    @State private var searchText = ""
    @State private var showingAddExercise = false

    private var filteredExercises: [Exercise] {
        guard !searchText.isEmpty else {
            return exercises
        }

        return exercises.filter {
            $0.name.localizedStandardContains(searchText) ||
            ($0.muscleGroup?.localizedStandardContains(searchText) ?? false)
        }
    }

    var body: some View {
        List {
            if filteredExercises.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "No Exercises Yet" : "No Results",
                    systemImage: "dumbbell",
                    description: Text(
                        searchText.isEmpty
                        ? "Add an exercise to start building your library."
                        : "Try searching for another exercise."
                    )
                )
            } else {
                ForEach(filteredExercises) { exercise in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)

                        if let muscleGroup = exercise.muscleGroup,
                           !muscleGroup.isEmpty {
                            Text(muscleGroup)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Exercise Library")
        .searchable(text: $searchText, prompt: "Search Exercises")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddExercise = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }
}
