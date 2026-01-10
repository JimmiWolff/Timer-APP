//
//  SetupView.swift
//  CircuitTimer
//
//  Configuration screen for setting up workout parameters
//

import SwiftUI

/// Setup screen for configuring workout parameters
struct SetupView: View {
    @StateObject private var viewModel = TimerViewModel()

    // Work interval
    @State private var workMinutes = 0
    @State private var workSeconds = 45

    // Rest interval
    @State private var restMinutes = 0
    @State private var restSeconds = 15

    // Rounds
    @State private var rounds = 8

    // Navigation
    @State private var navigateToTimer = false

    var body: some View {
        NavigationStack {
            Form {
                // Work interval section
                Section {
                    HStack {
                        Text("Minutes")
                        Spacer()
                        Picker("Work Minutes", selection: $workMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }

                    HStack {
                        Text("Seconds")
                        Spacer()
                        Picker("Work Seconds", selection: $workSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second)").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }
                } header: {
                    Text("Work Interval")
                } footer: {
                    Text("Duration of high-intensity work periods")
                }

                // Rest interval section
                Section {
                    HStack {
                        Text("Minutes")
                        Spacer()
                        Picker("Rest Minutes", selection: $restMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }

                    HStack {
                        Text("Seconds")
                        Spacer()
                        Picker("Rest Seconds", selection: $restSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second)").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }
                } header: {
                    Text("Rest Interval")
                } footer: {
                    Text("Duration of recovery periods between work intervals")
                }

                // Rounds section
                Section {
                    Picker("Number of Rounds", selection: $rounds) {
                        ForEach(1...Constants.TimerLimits.maxRounds, id: \.self) { round in
                            Text("\(round)").tag(round)
                        }
                    }
                    .pickerStyle(.wheel)
                } header: {
                    Text("Rounds")
                } footer: {
                    Text("Total number of work/rest cycles")
                }

                // Summary section
                Section {
                    HStack {
                        Text("Total Workout Time")
                        Spacer()
                        Text(totalWorkoutTime)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Summary")
                }

                // Quick presets
                Section {
                    Button("Tabata (30s/10s × 8)") {
                        setTabataPreset()
                    }

                    Button("Intermediate (45s/15s × 10)") {
                        setIntermediatePreset()
                    }

                    Button("Endurance (60s/30s × 6)") {
                        setEndurancePreset()
                    }
                } header: {
                    Text("Quick Presets")
                }
            }
            .navigationTitle("Circuit Timer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Start") {
                        startWorkout()
                    }
                    .disabled(!isConfigurationValid)
                    .bold()
                }
            }
            .navigationDestination(isPresented: $navigateToTimer) {
                TimerView(viewModel: viewModel)
            }
            .accessibilityIdentifier(Constants.Accessibility.setupView)
        }
    }

    // MARK: - Computed Properties

    /// Whether the configuration is valid
    private var isConfigurationValid: Bool {
        let totalWorkSeconds = workMinutes * 60 + workSeconds
        let totalRestSeconds = restMinutes * 60 + restSeconds
        return totalWorkSeconds > 0 && totalRestSeconds > 0 && rounds > 0
    }

    /// Total workout time formatted
    private var totalWorkoutTime: String {
        let workTime = workMinutes * 60 + workSeconds
        let restTime = restMinutes * 60 + restSeconds
        let totalSeconds = (workTime + restTime) * rounds - restTime
        return TimeInterval(totalSeconds).asCompact
    }

    // MARK: - Actions

    /// Start the workout
    private func startWorkout() {
        let config = TimerConfiguration(
            workTime: workMinutes * 60 + workSeconds,
            restTime: restMinutes * 60 + restSeconds,
            rounds: rounds
        )

        viewModel.configure(config)
        navigateToTimer = true
    }

    /// Set Tabata preset
    private func setTabataPreset() {
        workMinutes = 0
        workSeconds = 30
        restMinutes = 0
        restSeconds = 10
        rounds = 8
    }

    /// Set intermediate preset
    private func setIntermediatePreset() {
        workMinutes = 0
        workSeconds = 45
        restMinutes = 0
        restSeconds = 15
        rounds = 10
    }

    /// Set endurance preset
    private func setEndurancePreset() {
        workMinutes = 1
        workSeconds = 0
        restMinutes = 0
        restSeconds = 30
        rounds = 6
    }
}

// MARK: - Preview
#Preview {
    SetupView()
}
