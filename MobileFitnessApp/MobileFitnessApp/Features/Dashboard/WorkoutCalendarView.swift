//
//  WorkoutCalendarView.swift
//  MobileFitnessApp
//
//  Created by Ryan Domathoti on 11/9/26.
//

import SwiftUI
import SwiftData

struct WorkoutCalendarView: View {

    @Query(
        filter: #Predicate<WorkoutSession> { $0.isCompleted },
        sort: \WorkoutSession.startDate
    )
    private var sessions: [WorkoutSession]

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()

    @Environment(\.calendar) private var calendar
    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light

    var body: some View {
        let workoutsByDay = Dictionary(grouping: sessions) {
            calendar.startOfDay(for: $0.startDate)
        }
        let selectedWorkouts = workoutsByDay[calendar.startOfDay(for: selectedDate)] ?? []

        List {
            Section("Workout Calendar") {
                VStack(spacing: 12) {
                    monthHeader
                    weekdayHeader
                    monthGrid(workoutDays: Set(workoutsByDay.keys))
                }
                .themeListRow()
            }

            Section(selectedDate.formatted(date: .complete, time: .omitted)) {
                if selectedWorkouts.isEmpty {
                    Text("No completed workouts on this day.")
                        .foregroundStyle(.secondary)
                        .themeListRow()
                } else {
                    ForEach(selectedWorkouts) { session in
                        NavigationLink {
                            WorkoutDetailView(session: session)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.name)
                                    .font(.headline)
                                Text(session.startDate.formatted(date: .omitted, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                        .themeListRow()
                    }
                }
            }
        }
        .themeBackground()
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .accessibilityLabel("Previous month")
            }
            .buttonStyle(.borderless)

            Spacer()

            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .accessibilityLabel("Next month")
            }
            .buttonStyle(.borderless)
        }
    }

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        let ordered = Array(symbols[offset...] + symbols[..<offset])

        return HStack(spacing: 4) {
            ForEach(Array(ordered.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func monthGrid(workoutDays: Set<Date>) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7),
            spacing: 8
        ) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(for: date, hasWorkout: workoutDays.contains(calendar.startOfDay(for: date)))
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }

    private func dayCell(for date: Date, hasWorkout: Bool) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .foregroundStyle(theme.colorScheme == .light ? Color.black : Color.primary)

                Circle()
                    .fill(hasWorkout ? theme.accent : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? theme.accent.opacity(0.20) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityValue(hasWorkout ? "Completed workout" : "No completed workouts")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Helpers

    private var daysInMonth: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth),
              let dayCount = calendar.range(of: .day, in: .month, for: interval.start)?.count
        else { return [] }

        let weekday = calendar.component(.weekday, from: interval.start)
        let leadingBlanks = (weekday - calendar.firstWeekday + 7) % 7

        let days: [Date?] = (0..<dayCount).map {
            calendar.date(byAdding: .day, value: $0, to: interval.start)
        }

        return Array(repeating: nil, count: leadingBlanks) + days
    }

    private func changeMonth(by value: Int) {
        guard let currentMonth = calendar.dateInterval(of: .month, for: displayedMonth),
              let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth.start)
        else { return }

        displayedMonth = newMonth
        let today = Date()
        selectedDate = calendar.isDate(today, equalTo: newMonth, toGranularity: .month)
            ? today : newMonth
    }
}
