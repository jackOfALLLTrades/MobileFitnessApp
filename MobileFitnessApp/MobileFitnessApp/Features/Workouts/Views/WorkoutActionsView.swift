//
//  WorkoutActionsView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct WorkoutActionsView: View {

    let onAddExercise: () -> Void
    let onSettings: () -> Void
    let onDiscard: () -> Void

    var body: some View {
        Section {
            VStack(spacing: 12) {
                Button(action: onAddExercise) {
                    Label("Add Exercise", systemImage: "plus")
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

                HStack {
                    Button(action: onSettings) {
                        Label("Settings", systemImage: "gearshape")
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

                    Spacer()
                        .frame(width: 12)

                    Button(action: onDiscard) {
                        Label {
                            Text("Discard")
                        } icon: {
                            Image(systemName: "trash")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.quaternary.opacity(0.5))
                    )
                }
            }
            .padding(.vertical, 8)
            .listRowSeparator(.hidden)
        }
    }
}
