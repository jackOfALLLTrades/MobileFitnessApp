//
//  SettingsView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/9/26.
//

import SwiftUI

enum AppPreferences {
    static let historyPreviewCountKey = "historyPreviewCount"
    static let historyPreviewCounts = 3...5
    static let defaultHistoryPreviewCount = 5
    static let weightUnitKey = "workoutWeightUnit"
}

struct SettingsView: View {
    @AppStorage(AppPreferences.historyPreviewCountKey)
    private var historyPreviewCount = AppPreferences.defaultHistoryPreviewCount

    @AppStorage(AppPreferences.weightUnitKey)
    private var weightUnit: WorkoutWeightUnit = .pounds

    var body: some View {
        Form {
            Section("History") {
                Picker("Recent Workouts", selection: $historyPreviewCount) {
                    ForEach(AppPreferences.historyPreviewCounts, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
            }

            Section("Workout Logging") {
                Picker("Weight Units", selection: $weightUnit) {
                    ForEach(WorkoutWeightUnit.allCases, id: \.self) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}
