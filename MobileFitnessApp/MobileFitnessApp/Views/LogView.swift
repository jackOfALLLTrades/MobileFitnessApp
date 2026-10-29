//
//  LogView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//
import SwiftUI

struct LogView: View {
    private enum Mode: String, CaseIterable {
        case list = "List"
        case calendar = "Calendar"
    }

    @Environment(LogViewModel.self) private var logVM
    @State private var showingAdd = false
    @State private var mode = Mode.list

    var body: some View {
        NavigationStack {
            VStack {
                Picker("View", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if mode == .list {
                    sessionList
                } else {
                    CalendarView()
                }
            }
            .navigationTitle("Log")
            .toolbar {
                Button("Add", systemImage: "plus") { showingAdd = true }
            }
            .sheet(isPresented: $showingAdd) {
                AddSessionView()
            }
        }
    }

    private var sessionList: some View {
        List {
            ForEach(logVM.sessions) { session in
                NavigationLink {
                    SessionDetailView(session: session)
                } label: {
                    VStack(alignment: .leading) {
                        Text(session.name).font(.headline)
                        Text(session.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { logVM.deleteSession(at: $0) }
        }
        .overlay {
            if logVM.sessions.isEmpty {
                ContentUnavailableView("Nothing Logged", systemImage: "calendar", description: Text("Tap + to log a session."))
            }
        }
    }
}

struct AddSessionView: View {
    @Environment(WorkoutViewModel.self) private var workoutVM
    @Environment(LogViewModel.self) private var logVM
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var name = ""
    @State private var workoutID: UUID?

    private var selectedWorkout: Workout? {
        workoutVM.workouts.first { $0.id == workoutID }
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)

                Picker("Workout", selection: $workoutID) {
                    Text("None").tag(UUID?.none)
                    ForEach(workoutVM.workouts) { workout in
                        Text(workout.name).tag(Optional(workout.id))
                    }
                }

                TextField("Name (optional if workout chosen)", text: $name)
            }
            .navigationTitle("Log Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let sessionName = name.isEmpty ? (selectedWorkout?.name ?? "") : name
                        logVM.logSession(session: Session(date: date,
                                                          name: sessionName,
                                                          workout: selectedWorkout,
                                                          exercises: selectedWorkout?.exercises))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty && selectedWorkout == nil)
                }
            }
        }
    }
}

struct SessionDetailView: View {
    let session: Session

    var body: some View {
        List {
            Section {
                LabeledContent("Date", value: session.date.formatted(date: .abbreviated, time: .omitted))
                LabeledContent("Volume", value: "\(session.volume.formatted()) lb")
            }

            ForEach(session.exercises ?? []) { exercise in
                Section(exercise.name) {
                    ForEach(exercise.sets.indices, id: \.self) { index in
                        Text("Set \(index + 1): \(exercise.sets[index].summary)")
                    }
                }
            }
        }
        .navigationTitle(session.name)
    }
}

#Preview {
    LogView()
        .environment(WorkoutViewModel())
        .environment(LogViewModel())
}
