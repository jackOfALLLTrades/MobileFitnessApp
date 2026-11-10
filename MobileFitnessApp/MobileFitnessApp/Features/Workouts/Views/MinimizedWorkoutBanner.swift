//
//  MinimizedWorkoutBanner.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct MinimizedWorkoutBanner: View {
    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light

    let session: WorkoutSession
    let onReopen: () -> Void
    let onDiscard: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            Button {
                onReopen()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.up")
                        .font(.headline)
                        .foregroundStyle(theme.accent)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            Text(
                                WorkoutDurationFormatter.string(
                                    since: session.startDate,
                                    now: context.date
                                )
                            )
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                onDiscard()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                    .frame(width: 34, height: 34)
                    .background(.quaternary.opacity(0.7))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cancel workout")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .fill(.ultraThinMaterial)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }

}
