//
//  WorkoutHeaderView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct WorkoutHeaderView: View {

    let startDate: Date
    let exerciseCount: Int

    var body: some View {
        Section {
            HStack(alignment: .center) {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(
                            elapsedTime(
                                since: startDate,
                                now: context.date
                            )
                        )
                        .font(.title2.weight(.semibold).monospacedDigit())

                        Text("WORKOUT DURATION")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(exerciseCount)")
                        .font(.title2.weight(.semibold))

                    Text("EXERCISES")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
            .listRowSeparator(.hidden)
        }
    }

    private func elapsedTime(
        since startDate: Date,
        now: Date
    ) -> String {
        let totalSeconds = max(
            0,
            Int(now.timeIntervalSince(startDate))
        )

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(
            format: "%02d:%02d:%02d",
            hours,
            minutes,
            seconds
        )
    }
}
