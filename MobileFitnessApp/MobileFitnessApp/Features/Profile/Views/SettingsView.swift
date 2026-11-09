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
    static let themeKey = "bodiesTheme"
    static let weightUnitKey = "workoutWeightUnit"
}

struct SettingsView: View {
    @AppStorage(AppPreferences.historyPreviewCountKey)
    private var historyPreviewCount = AppPreferences.defaultHistoryPreviewCount

    @AppStorage(AppPreferences.weightUnitKey)
    private var weightUnit: WorkoutWeightUnit = .pounds

    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light
    @State private var showingThemePicker = false

    var body: some View {
        Form {
            Section("History") {
                Picker("Recent Workouts", selection: $historyPreviewCount) {
                    ForEach(AppPreferences.historyPreviewCounts, id: \.self) { count in
                        Text("\(count)").tag(count)
                    }
                }
                .tint(theme.accent)
                .id(theme)
            }
            .themeListRow()

            Section("Workout Logging") {
                Picker("Weight Units", selection: $weightUnit) {
                    ForEach(WorkoutWeightUnit.allCases, id: \.self) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                .tint(theme.accent)
                .id(theme)
            }
            .themeListRow()

            Section("Appearance") {
                Button {
                    showingThemePicker = true
                } label: {
                    LabeledContent("Theme", value: theme.rawValue)
                }
            }
            .themeListRow()
        }
        .themeBackground()
        .navigationTitle("Settings")
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerView(theme: $theme)
        }
    }
}
