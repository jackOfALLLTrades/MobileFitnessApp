//
//  CalendarView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/27/26.
//
import SwiftUI

//A month grid that puts a dot under every day with a logged session
struct CalendarView: View {
    @Environment(LogViewModel.self) private var logVM
    @State private var month = Date()
    @State private var selectedDay = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    //Every day of the shown month, with nil padding so day 1 lands on the right weekday
    private var days: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        let count = calendar.range(of: .day, in: .month, for: month)?.count ?? 30

        var result: [Date?] = Array(repeating: nil, count: leading)
        for offset in 0..<count {
            result.append(calendar.date(byAdding: .day, value: offset, to: interval.start))
        }
        return result
    }

    private var weekdayHeaders: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }

    private var sessionsOnSelectedDay: [Session] {
        logVM.sessions.filter { calendar.isDate($0.date, inSameDayAs: selectedDay) }
    }

    private func hasSession(on day: Date) -> Bool {
        logVM.sessions.contains { calendar.isDate($0.date, inSameDayAs: day) }
    }

    private func changeMonth(by value: Int) {
        month = calendar.date(byAdding: .month, value: value, to: month) ?? month
    }

    var body: some View {
        VStack {
            HStack {
                Button("Previous Month", systemImage: "chevron.left") { changeMonth(by: -1) }
                Spacer()
                Text(month.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                Spacer()
                Button("Next Month", systemImage: "chevron.right") { changeMonth(by: 1) }
            }
            .labelStyle(.iconOnly)
            .padding(.horizontal)

            LazyVGrid(columns: columns) {
                ForEach(weekdayHeaders.indices, id: \.self) { index in
                    Text(weekdayHeaders[index])
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ForEach(days.indices, id: \.self) { index in
                    if let day = days[index] {
                        dayCell(day)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
            .padding(.horizontal)

            List {
                Section(selectedDay.formatted(date: .complete, time: .omitted)) {
                    if sessionsOnSelectedDay.isEmpty {
                        Text("No workouts logged")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(sessionsOnSelectedDay) { session in
                        NavigationLink(session.name) {
                            SessionDetailView(session: session)
                        }
                    }
                }
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let isSelected = calendar.isDate(day, inSameDayAs: selectedDay)
        let isToday = calendar.isDateInToday(day)

        return Button {
            selectedDay = day
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: day))")
                    .fontWeight(isToday ? .bold : .regular)
                Circle()
                    .frame(width: 6, height: 6)
                    .opacity(hasSession(on: day) ? 1 : 0)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .clipShape(.rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
    .environment(LogViewModel())
}
