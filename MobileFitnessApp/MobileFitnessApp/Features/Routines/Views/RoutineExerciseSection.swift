//
//  RoutineExerciseSection.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct RoutineExerciseSection: View {
    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light

    let exercise: Exercise
    let rows: [UUID]
    let onReorder: () -> Void
    let onReplace: () -> Void
    let onDelete: () -> Void
    let onRemoveSet: (UUID) -> Void
    let onAddSet: () -> Void

    var body: some View {
        Section {

            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Menu {
                    Button {
                        onReorder()
                    } label: {
                        Label(
                            "Reorder",
                            systemImage: "arrow.up.arrow.down"
                        )
                    }

                    Button {
                        onReplace()
                    } label: {
                        Label(
                            "Replace Exercise",
                            systemImage: "arrow.left.arrow.right"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label(
                            "Delete Exercise",
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
            .listRowSeparator(.hidden)
            .themeListRow()

            SetColumnHeadings(loggingMode: exercise.loggingMode)
                .themeListRow()

            ForEach(Array(rows.enumerated()), id: \.element) { index, rowID in
                RoutineSetRow(number: index + 1, showsWeight: exercise.loggingMode.showsWeight)
                    .themeListRow()
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: false
                ) {
                    if rows.count > 1 {
                        Button(role: .destructive) {
                            onRemoveSet(rowID)
                        } label: {
                            Label(
                                "Remove Set",
                                systemImage: "trash"
                            )
                        }
                    }
                }
            }

            Button {
                onAddSet()
            } label: {
                Label("Add Set", systemImage: "plus")
                    .foregroundStyle(theme.accent)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(theme.accent)
            .listRowSeparator(.hidden)
            .themeListRow()
        }
    }

}
