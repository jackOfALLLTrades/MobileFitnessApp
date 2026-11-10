//
//  CalenderView.swift
//  MobileFitnessApp
//
//  Created by Ryan Domathoti on 11/9/26.
//

import SwiftUI
import SwiftData

struct CalendarView: View {

    @Query(sort: \WorkoutSession.startDate)
    private var sessions: [WorkoutSession]

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            List {
                Section {
                    monthHeader
                    weekdayHeader
                    monthGrid
                }

                Section(selectedDate.formatted(date: .complete, time: .omitted)) {
                    if sessionsOnSelectedDate.isEmpty {
                        Text("No workouts on this day.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(sessionsOnSelectedDate) { session in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.name)
                                    .font(.headline)

                                Text(
                                    session.startDate.formatted(
                                        date: .omitted,
                                        time: .shortened
                                    ) + " · " +
                                    (session.isCompleted ? "Completed" : "In progress")
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
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
            }
            .buttonStyle(.borderless)
        }
    }

    private var weekdayHeader: some View {
        let symbols = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        let ordered = Array(symbols[offset...] + symbols[..<offset])

        return HStack(spacing: 0) {
            ForEach(Array(ordered.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }



    private var monthGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 7),
            spacing: 8
        ) {
            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(for: date)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? Color.white : Color.primary)

                Circle()
                    .fill(hasWorkout(on: date)
                          ? (isSelected ? Color.white : Color.blue)
                          : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
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

    private var sessionsOnSelectedDate: [WorkoutSession] {
        sessions.filter { calendar.isDate($0.startDate, inSameDayAs: selectedDate) }
    }

    private func hasWorkout(on date: Date) -> Bool {
        sessions.contains { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: [
            Exercise.self,
            Routine.self,
            RoutineExercise.self,
            WorkoutSession.self,
            WorkoutExercise.self,
            WorkoutSet.self
        ])
}
