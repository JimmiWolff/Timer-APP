//
//  TimerView.swift
//  CircuitTimer
//
//  Main timer display during workout
//

import SwiftUI

/// Main timer view showing workout progress
struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background color based on state
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: Constants.Layout.largeSpacing) {
                Spacer()

                // State indicator (WORK, REST, etc.)
                Text(viewModel.currentStateText)
                    .font(.system(
                        size: Constants.FontSize.mediumState,
                        weight: .bold
                    ))
                    .foregroundColor(.white)
                    .accessibilityLabel("Current state: \(viewModel.currentStateText)")
                    .accessibilityIdentifier(Constants.Accessibility.stateLabel)

                // Progress circle with time display
                ZStack {
                    CircularProgressView(
                        progress: viewModel.progress,
                        color: .white,
                        lineWidth: Constants.Layout.progressLineWidth
                    )
                    .frame(
                        width: Constants.Layout.progressCircleSize,
                        height: Constants.Layout.progressCircleSize
                    )

                    TimeDisplayView(
                        timeRemaining: viewModel.timeRemaining,
                        color: .white
                    )
                }

                // Round indicator
                Text("Round \(viewModel.currentRound) / \(viewModel.totalRounds)")
                    .font(.system(
                        size: Constants.FontSize.roundIndicator,
                        weight: .medium
                    ))
                    .foregroundColor(.white.opacity(0.9))
                    .accessibilityLabel("Round \(viewModel.currentRound) of \(viewModel.totalRounds)")
                    .accessibilityIdentifier(Constants.Accessibility.roundLabel)

                Spacer()

                // Control buttons
                ControlButtonsView(
                    state: viewModel.state,
                    onStart: {
                        viewModel.start()
                    },
                    onPause: {
                        viewModel.pause()
                    },
                    onResume: {
                        viewModel.resume()
                    },
                    onReset: {
                        viewModel.reset()
                        dismiss()
                    }
                )
                .padding(.bottom, Constants.Layout.largeSpacing)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(viewModel.state != .idle)
        .toolbar {
            if viewModel.state == .idle {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onAppear {
            // Start the workout when view appears
            if viewModel.state == .idle {
                viewModel.start()
            }
        }
        .accessibilityIdentifier(Constants.Accessibility.timerView)
    }

    // MARK: - Computed Properties

    /// Background color based on timer state
    private var backgroundColor: Color {
        Color.forState(viewModel.state)
    }

    // MARK: - Scene Phase Handling

    /// Handle scene phase changes (foreground/background)
    /// - Parameter phase: New scene phase
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // App came to foreground - synchronize state
            print("TimerView: App active, synchronizing state")
            viewModel.synchronizeState()

        case .background:
            // App went to background - timer continues via date calculations
            print("TimerView: App backgrounded")

        case .inactive:
            // Transitional state
            break

        @unknown default:
            break
        }
    }
}

// MARK: - Preview
#Preview("TimerView - Work") {
    NavigationStack {
        TimerView(viewModel: {
            let vm = TimerViewModel()
            vm.configure(TimerConfiguration(workTime: 30, restTime: 10, rounds: 8))
            return vm
        }())
    }
}

#Preview("TimerView - Rest") {
    NavigationStack {
        TimerView(viewModel: {
            let vm = TimerViewModel()
            vm.configure(TimerConfiguration(workTime: 30, restTime: 10, rounds: 8))
            // Simulate rest state
            return vm
        }())
    }
}
