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
                            WorkoutDurationFormatter.string(
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
}
