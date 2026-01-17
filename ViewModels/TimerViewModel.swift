//
//  TimerViewModel.swift
//  CircuitTimer
//
//  Main orchestration layer coordinating timer, audio, and Live Activities
//

import Foundation
import Combine
import SwiftUI
import UIKit

/// Main ViewModel orchestrating timer functionality
///
/// This is the single source of truth for timer state. It coordinates:
/// - TimerEngine (date-based calculations)
/// - AudioManager (beep playback with ducking)
/// - LiveActivityManager (Lock Screen display)
@MainActor
class TimerViewModel: ObservableObject {
    // MARK: - Published Properties (Observable by UI)

    /// Current timer state
    @Published var state: TimerState = .idle

    /// Time remaining in current interval (seconds)
    @Published var timeRemaining: TimeInterval = 0

    /// Current round number (1-indexed)
    @Published var currentRound: Int = 1

    /// Progress of current interval (0.0 to 1.0)
    @Published var progress: Double = 0.0

    // MARK: - Services

    /// Date-based timer engine
    private let timerEngine = TimerEngine()

    /// Audio manager for beeps
    private let audioManager = AudioManager()

    /// Live Activity manager (iOS 16.1+)
    private var liveActivityManager: LiveActivityManager?

    // MARK: - Configuration

    /// Current timer configuration
    private var config: TimerConfiguration?

    /// Total number of rounds
    var totalRounds: Int {
        config?.rounds ?? 0
    }

    /// Current interval type
    private var currentIntervalType: IntervalType {
        state == .work ? .work : .rest
    }

    /// State before pausing (to restore on resume)
    private var stateBeforePause: TimerState = .idle

    // MARK: - Timer

    /// Timer for UI updates (0.1s interval)
    private var uiUpdateTimer: AnyCancellable?

    /// Notification observer for pause/resume from Live Activity
    private var pauseResumeObserver: AnyCancellable?

    // MARK: - Initialization

    init() {
        // Initialize Live Activity manager if available
        if #available(iOS 16.1, *) {
            liveActivityManager = LiveActivityManager()
        }

        // Observe pause/resume notifications from Live Activity
        setupPauseResumeObserver()
    }

    // MARK: - Public Methods

    /// Configure the timer with workout settings
    /// - Parameter configuration: Timer configuration
    func configure(_ configuration: TimerConfiguration) {
        guard configuration.isValid else {
            print("TimerViewModel: Invalid configuration")
            return
        }
        self.config = configuration
    }

    /// Start the workout timer
    func start() {
        guard let config = config else {
            print("TimerViewModel: No configuration set")
            return
        }

        // Initialize state
        state = .work
        currentRound = 1
        stateBeforePause = .work

        // Start first work interval
        timerEngine.startInterval(duration: TimeInterval(config.workTime))

        // Play work start beep
        audioManager.playBeep(.workStart)

        // Start Live Activity
        if #available(iOS 16.1, *) {
            Task {
                try? await liveActivityManager?.startLiveActivity(
                    config: config,
                    currentState: .work,
                    currentRound: 1,
                    intervalEndDate: timerEngine.intervalEndDate ?? Date()
                )
            }
        }

        // Start UI update timer
        startUIUpdateTimer()
    }

    /// Pause the timer
    func pause() {
        guard state.canPause else { return }

        // Store state before pausing
        stateBeforePause = state

        // Pause timer engine
        timerEngine.pause()

        // Update state
        state = .paused

        // Update Live Activity
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityManager?.updateLiveActivity(
                    currentState: .paused,
                    currentRound: currentRound,
                    totalRounds: totalRounds,
                    intervalEndDate: Date().addingTimeInterval(timeRemaining),
                    isPaused: true
                )
            }
        }
    }

    /// Resume from paused state
    func resume() {
        guard state.canResume else { return }

        // Restore previous state
        state = stateBeforePause

        // Resume timer engine
        timerEngine.resume()

        // Update Live Activity
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityManager?.updateLiveActivity(
                    currentState: state,
                    currentRound: currentRound,
                    totalRounds: totalRounds,
                    intervalEndDate: timerEngine.intervalEndDate ?? Date(),
                    isPaused: false
                )
            }
        }
    }

    /// Reset the timer to idle state
    func reset() {
        // Stop UI timer
        uiUpdateTimer?.cancel()

        // Reset engine
        timerEngine.reset()

        // Reset state
        state = .idle
        currentRound = 1
        timeRemaining = 0
        progress = 0.0

        // End Live Activity
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityManager?.endLiveActivity()
            }
        }
    }

    /// Synchronize state after returning from background
    ///
    /// This method catches up on any missed state transitions while the app
    /// was suspended. It's called when the app foregrounds via ScenePhase detection.
    func synchronizeState() {
        guard state.isActive else { return }

        // Process all missed state transitions
        while timerEngine.hasIntervalEnded() &&
              state != .finished &&
              state != .paused {
            advanceToNextInterval()
        }

        // Update UI with current state
        updateState()

        print("TimerViewModel: Synchronized state - \(state), round \(currentRound)/\(totalRounds)")
    }

    // MARK: - Private Methods

    /// Start the UI update timer
    private func startUIUpdateTimer() {
        uiUpdateTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateState()
            }
    }

    /// Update state on each timer tick
    private func updateState() {
        guard let config = config, state.isActive else { return }

        // Update time remaining
        timeRemaining = timerEngine.timeRemaining()

        // Update progress
        let totalDuration = state == .work ?
            TimeInterval(config.workTime) :
            TimeInterval(config.restTime)
        progress = timerEngine.progress(totalDuration: totalDuration)

        // Check for state transitions
        if timerEngine.hasIntervalEnded() {
            advanceToNextInterval()
        }
    }

    /// Advance to the next interval (Work → Rest → Work, etc.)
    private func advanceToNextInterval() {
        guard let config = config else { return }

        let previousState = state

        switch state {
        case .work:
            // Work → Rest
            state = .rest
            stateBeforePause = .rest
            timerEngine.startInterval(duration: TimeInterval(config.restTime))
            audioManager.playBeep(.restStart)

        case .rest:
            // Rest → Work (next round) or Finished
            if currentRound < config.rounds {
                // Next round
                currentRound += 1
                state = .work
                stateBeforePause = .work
                timerEngine.startInterval(duration: TimeInterval(config.workTime))
                audioManager.playBeep(.workStart)
            } else {
                // Workout complete
                completeWorkout()
                return
            }

        default:
            break
        }

        print("TimerViewModel: State transition \(previousState.displayName) → \(state.displayName), Round \(currentRound)/\(totalRounds)")

        // Update Live Activity with new state
        // CRITICAL: Use background task to ensure update completes even when app is backgrounded
        if #available(iOS 16.1, *) {
            // Get fresh interval end date immediately after starting new interval
            guard let intervalEndDate = timerEngine.intervalEndDate else {
                print("TimerViewModel: WARNING - No interval end date available")
                return
            }

            // Capture state variables before async task
            let capturedState = state
            let capturedRound = currentRound
            let capturedTotal = totalRounds

            // Use high-priority task to ensure execution
            Task(priority: .high) { @MainActor in
                await self.updateLiveActivityWithBackgroundTask(
                    currentState: capturedState,
                    currentRound: capturedRound,
                    totalRounds: capturedTotal,
                    intervalEndDate: intervalEndDate,
                    isPaused: false
                )
            }
        }
    }

    /// Complete the workout
    private func completeWorkout() {
        state = .finished
        uiUpdateTimer?.cancel()
        timeRemaining = 0
        progress = 1.0

        // Play completion beep
        audioManager.playBeep(.workoutComplete)

        // End Live Activity
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityManager?.endLiveActivity(
                    dismissalPolicy: .after(Date().addingTimeInterval(10))
                )
            }
        }

        print("TimerViewModel: Workout complete!")
    }

    /// Setup observer for pause/resume from Live Activity
    private func setupPauseResumeObserver() {
        pauseResumeObserver = NotificationCenter.default
            .publisher(for: .pauseResumeTimer)
            .sink { [weak self] _ in
                Task { @MainActor in
                    guard let self = self else { return }
                    if self.state.canPause {
                        self.pause()
                    } else if self.state.canResume {
                        self.resume()
                    }
                }
            }
    }

    /// Update Live Activity with background task protection
    ///
    /// This ensures the update completes even when the app is suspended (e.g., when music is playing)
    @available(iOS 16.1, *)
    private func updateLiveActivityWithBackgroundTask(
        currentState: TimerState,
        currentRound: Int,
        totalRounds: Int,
        intervalEndDate: Date,
        isPaused: Bool
    ) async {
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

        print("LiveActivity: Starting background task for \(currentState.displayName) transition")

        // Request background time to complete the update
        backgroundTaskID = await UIApplication.shared.beginBackgroundTask {
            // Cleanup when time expires
            print("LiveActivity: Background task time expiring, cleaning up")
            if backgroundTaskID != .invalid {
                Task { @MainActor in
                    await UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    backgroundTaskID = .invalid
                }
            }
        }

        guard backgroundTaskID != .invalid else {
            print("LiveActivity: ERROR - Failed to start background task")
            return
        }

        print("LiveActivity: Background task started with ID \(backgroundTaskID.rawValue)")

        // Update the Live Activity with explicit date logging
        let timeUntilEnd = intervalEndDate.timeIntervalSinceNow
        print("LiveActivity: Updating to \(currentState.displayName), Round \(currentRound)/\(totalRounds), Time until end: \(timeUntilEnd)s")

        await liveActivityManager?.updateLiveActivity(
            currentState: currentState,
            currentRound: currentRound,
            totalRounds: totalRounds,
            intervalEndDate: intervalEndDate,
            isPaused: isPaused
        )

        print("LiveActivity: Update completed, ending background task")

        // End background task
        await UIApplication.shared.endBackgroundTask(backgroundTaskID)
        print("LiveActivity: Background task ended")
    }

    // MARK: - Computed Properties for UI

    /// Display text for current state
    var currentStateText: String {
        state.displayName
    }

    /// Formatted time remaining (MM:SS)
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Whether sounds are enabled
    var soundsEnabled: Bool {
        audioManager.soundsEnabled
    }

    /// Toggle sounds on/off
    func toggleSounds() {
        audioManager.toggleSounds()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    /// Notification posted when pause/resume button tapped on Live Activity
    static let pauseResumeTimer = Notification.Name("pauseResumeTimer")
}
