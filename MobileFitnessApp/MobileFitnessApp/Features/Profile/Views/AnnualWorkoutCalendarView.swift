//
//  AnnualWorkoutCalendarView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/9/26.
//

import SwiftUI
import SwiftData

struct AnnualWorkoutCalendarView: View {
    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light
    @Query private var completedWorkouts: [WorkoutSession]

    private let calendar: Calendar
    private let firstDay: Date
    private let nextYear: Date
    private let cellSize: CGFloat = 12
    private let spacing: CGFloat = 3
    private let monthLabelHeight: CGFloat = 16

    init(calendar preferredCalendar: Calendar, now: Date = .now) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = preferredCalendar.locale
        calendar.timeZone = preferredCalendar.timeZone
        calendar.firstWeekday = preferredCalendar.firstWeekday
        self.calendar = calendar

        let year = calendar.dateInterval(of: .year, for: now)
        let firstDay = year?.start ?? now
        let nextYear = year?.end ?? now
        self.firstDay = firstDay
        self.nextYear = nextYear

        _completedWorkouts = Query(filter: #Predicate<WorkoutSession> {
            $0.isCompleted && $0.startDate >= firstDay && $0.startDate < nextYear
        })
    }

    // MARK: - Calendar Grid

    var body: some View {
        let workoutDays = Set(completedWorkouts.map { calendar.startOfDay(for: $0.startDate) })

        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: spacing) {
                    weekdayLabels
                    ForEach(weekStarts, id: \.self) { weekStart in
                        weekColumn(starting: weekStart, workoutDays: workoutDays)
                    }
                }
                .padding(.bottom, 4)
                .padding(.trailing, 16)
            }
            .defaultScrollAnchor(.leading)
            .accessibilityLabel("Workout days this year")

            HStack(spacing: 6) {
                Text(calendar.component(.year, from: firstDay).formatted(.number.grouping(.never)))
                Spacer()
                legendItem("No workout", color: .secondary.opacity(0.2))
                legendItem("Workout", color: theme.accent)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var weekdayLabels: some View {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1

        return VStack(spacing: spacing) {
            Color.clear.frame(width: cellSize, height: monthLabelHeight)
            ForEach(symbols.indices, id: \.self) { offset in
                Text(symbols[(firstIndex + offset) % symbols.count])
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: cellSize, height: cellSize)
            }
        }
        .accessibilityHidden(true)
    }

    private func weekColumn(starting weekStart: Date, workoutDays: Set<Date>) -> some View {
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        let monthStart = days.first {
            $0 >= firstDay && $0 < nextYear && calendar.component(.day, from: $0) == 1
        }

        return VStack(spacing: spacing) {
            Color.clear
                .frame(width: cellSize, height: monthLabelHeight)
                .overlay(alignment: .leading) {
                    if let monthStart {
                        Text(calendar.shortMonthSymbols[calendar.component(.month, from: monthStart) - 1])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize()
                            .accessibilityHidden(true)
                    }
                }

            ForEach(days, id: \.self) { day in
                if day >= firstDay && day < nextYear {
                    let hasWorkout = workoutDays.contains(calendar.startOfDay(for: day))
                    square(hasWorkout ? theme.accent : .secondary.opacity(0.2))
                        .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
                        .accessibilityValue(hasWorkout ? "Workout completed" : "No workout")
                } else {
                    Color.clear.frame(width: cellSize, height: cellSize)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private var weekStarts: [Date] {
        guard var week = calendar.dateInterval(of: .weekOfYear, for: firstDay)?.start else {
            return []
        }
        week = calendar.startOfDay(for: week)

        var starts: [Date] = []
        while week < nextYear {
            starts.append(week)
            guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: week) else { break }
            week = calendar.startOfDay(for: next)
        }
        return starts
    }

    private func square(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: cellSize, height: cellSize)
    }

    private func legendItem(_ label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            square(color).accessibilityHidden(true)
            Text(label)
        }
    }
}
