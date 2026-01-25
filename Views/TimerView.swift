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
            // Animated gradient background based on state
            Constants.Gradients.gradient(for: viewModel.state)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: Constants.Animation.backgroundTransition), value: viewModel.state)

            VStack(spacing: 40) {
                // Title
                Text("The Wolff Timer")
                    .font(.system(size: Constants.FontSize.timerTitle, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                Spacer()

                // State Badge with pulse animation
                StateBadgeView(state: viewModel.state)
                    .accessibilityLabel("Current state: \(viewModel.currentStateText)")
                    .accessibilityIdentifier(Constants.Accessibility.stateLabel)

                // Timer Display with integrated progress ring
                GlassmorphicTimerDisplay(
                    timeRemaining: viewModel.timeRemaining,
                    progress: viewModel.progress,
                    state: viewModel.state,
                    currentRound: viewModel.currentRound,
                    totalRounds: viewModel.totalRounds,
                    currentSet: viewModel.currentSet,
                    totalSets: viewModel.totalSets
                )

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
            // Start observing widget commands
            viewModel.startObservingWidgetCommands()

            // Start the workout when view appears
            if viewModel.state == .idle {
                viewModel.start()
            }
        }
        .onDisappear {
            // Stop observing when leaving timer view
            viewModel.stopObservingWidgetCommands()
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
            // App came to foreground - synchronize state and restart widget command observation
            print("TimerView: App active, synchronizing state and restarting command observation")
            viewModel.synchronizeState()
            // Restart observing (this also checks for pending commands immediately)
            viewModel.startObservingWidgetCommands()

        case .background:
            // App went to background - keep polling active for when app is still running
            // iOS will suspend us eventually, but we can still process commands until then
            print("TimerView: App backgrounded (polling continues)")

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
