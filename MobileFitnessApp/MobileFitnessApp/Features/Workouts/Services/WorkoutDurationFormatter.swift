//
//  WorkoutDurationFormatter.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import Foundation

enum WorkoutDurationFormatter {
    static func string(
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

        guard hours > 0 else {
            return String(format: "%d:%02d", minutes, seconds)
        }

        return String(
            format: "%d:%02d:%02d",
            hours,
            minutes,
            seconds
        )
    }
}
