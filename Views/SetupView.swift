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

    // Sets
    @State private var sets = 1

    // Rest between sets
    @State private var restBetweenSetsMinutes = 0
    @State private var restBetweenSetsSeconds = 0

    // Navigation
    @State private var navigateToTimer = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background (idle state)
                Constants.Gradients.idle
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Title
                    Text("The Wolff Timer")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                    // Configuration Panel (Glass Card) - Compact
                    VStack(spacing: 12) {
                        // Work & Rest Intervals (Side by Side)
                        HStack(spacing: 16) {
                            CompactConfigSection(title: "Work") {
                                CompactTimePicker(
                                    minutes: $workMinutes,
                                    seconds: $workSeconds
                                )
                            }

                            Divider()
                                .background(Color.white.opacity(0.3))
                                .frame(height: 90)

                            CompactConfigSection(title: "Rest") {
                                CompactTimePicker(
                                    minutes: $restMinutes,
                                    seconds: $restSeconds
                                )
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.3))

                        // Rounds & Sets (Side by Side)
                        HStack(spacing: 16) {
                            CompactConfigSection(title: "Rounds") {
                                Picker("Rounds", selection: $rounds) {
                                    ForEach(1...Constants.TimerLimits.maxRounds, id: \.self) { round in
                                        Text("\(round)").tag(round)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 80, height: 80)
                            }

                            Divider()
                                .background(Color.white.opacity(0.3))
                                .frame(height: 80)

                            CompactConfigSection(title: "Sets") {
                                Picker("Sets", selection: $sets) {
                                    ForEach(1...20, id: \.self) { set in
                                        Text("\(set)").tag(set)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 80, height: 80)
                            }
                        }

                        // Rest Between Sets (only if multiple sets)
                        if sets > 1 {
                            Divider()
                                .background(Color.white.opacity(0.3))

                            CompactConfigSection(title: "Rest Between Sets") {
                                CompactTimePicker(
                                    minutes: $restBetweenSetsMinutes,
                                    seconds: $restBetweenSetsSeconds
                                )
                            }
                        }

                        // Total Workout Time
                        Divider()
                            .background(Color.white.opacity(0.3))

                        HStack {
                            Text("Total Time")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Text(totalWorkoutTime)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(20)
                    .glassCard()
                    .padding(.horizontal)

                    Spacer()

                    // Start Button (Large, Prominent)
                    Button(action: startWorkout) {
                        Text("START WORKOUT")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .glassButton()
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .disabled(!isConfigurationValid)
                    .opacity(isConfigurationValid ? 1.0 : 0.5)
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
            rounds: rounds,
            sets: sets,
            restBetweenSets: restBetweenSetsMinutes * 60 + restBetweenSetsSeconds
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
        sets = 1
        restBetweenSetsMinutes = 0
        restBetweenSetsSeconds = 0
    }

    /// Set intermediate preset
    private func setIntermediatePreset() {
        workMinutes = 0
        workSeconds = 45
        restMinutes = 0
        restSeconds = 15
        rounds = 10
        sets = 1
        restBetweenSetsMinutes = 0
        restBetweenSetsSeconds = 0
    }

    /// Set endurance preset
    private func setEndurancePreset() {
        workMinutes = 1
        workSeconds = 0
        restMinutes = 0
        restSeconds = 30
        rounds = 6
        sets = 3
        restBetweenSetsMinutes = 2
        restBetweenSetsSeconds = 0
    }
}

// MARK: - Helper Components

/// Compact configuration section with title and content
struct CompactConfigSection<Content: View>: View {
    let title: String
    let content: () -> Content

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            content()
        }
        .frame(maxWidth: .infinity)
    }
}

/// Compact time picker component (minutes and seconds)
struct CompactTimePicker: View {
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        HStack(spacing: 12) {
            // Minutes
            VStack(spacing: 4) {
                Text("MIN")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)")
                            .foregroundColor(.white)
                            .tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 70, height: 80)
            }

            Text(":")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 16)

            // Seconds
            VStack(spacing: 4) {
                Text("SEC")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                Picker("Seconds", selection: $seconds) {
                    ForEach(0..<60) { second in
                        Text("\(second)")
                            .foregroundColor(.white)
                            .tag(second)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 70, height: 80)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SetupView()
}
