//
//  RoutineCardView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct RoutineCardView: View {
    let routine: Routine
    let canStart: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onStart: () -> Void

    var body: some View {
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
                        onEdit()
                    } label: {
                        Label(
                            "Edit Routine",
                            systemImage: "pencil"
                        )
                    }

                    Button(role: .destructive) {
                        onDelete()
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
                onStart()
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
            .disabled(!canStart)
        }
        .padding(.vertical, 8)
    }
}
