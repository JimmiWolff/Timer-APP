//
//  TimerViewModel.swift
//  CircuitTimer
//
//  Main orchestration layer coordinating timer, audio, and Live Activities
//

import Foundation
import Combine
import SwiftUI

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

    /// Current set number (1-indexed)
    @Published var currentSet: Int = 1

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

    /// Total number of sets
    var totalSets: Int {
        config?.sets ?? 1
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
        currentSet = 1
        stateBeforePause = .work

        // Start first work interval
        timerEngine.startInterval(duration: TimeInterval(config.workTime))

        // Play work start beep
        audioManager.playBeep(.workStart)

        // Schedule background wake-ups for state transitions
        // This ensures the app wakes up to update Live Activities even when suspended
        BackgroundUpdateScheduler.shared.scheduleTransitionWakeUps(
            workDuration: config.workTime,
            restDuration: config.restTime,
            rounds: config.rounds,
            sets: config.sets,
            restBetweenSets: config.restBetweenSets
        )

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
        print("TimerViewModel: pause() called - state before: \(state)")
        guard state.canPause else {
            print("TimerViewModel: pause() - cannot pause, state is \(state)")
            return
        }

        // Store state before pausing
        stateBeforePause = state

        // Pause timer engine
        timerEngine.pause()

        // Cancel scheduled wake-up notifications (they're no longer valid)
        BackgroundUpdateScheduler.shared.cancelAllWakeUps()
        print("TimerViewModel: pause() - cancelled scheduled notifications")

        // Update state
        state = .paused
        print("TimerViewModel: pause() - state now: \(state), timer engine paused")

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
        print("TimerViewModel: resume() called - state before: \(state)")
        guard state.canResume else {
            print("TimerViewModel: resume() - cannot resume, state is \(state)")
            return
        }

        // Restore previous state
        state = stateBeforePause

        // Resume timer engine
        timerEngine.resume()
        let freshTimeRemaining = timerEngine.timeRemaining()
        print("TimerViewModel: resume() - state now: \(state), timer engine resumed, timeRemaining: \(freshTimeRemaining)s")

        // Reschedule background wake-ups from current point
        // Use freshTimeRemaining from engine, not cached timeRemaining property
        if let config = config {
            BackgroundUpdateScheduler.shared.scheduleRemainingWakeUps(
                timeRemainingInInterval: freshTimeRemaining,
                currentState: state.displayName,
                currentRound: currentRound,
                currentSet: currentSet,
                workDuration: config.workTime,
                restDuration: config.restTime,
                rounds: config.rounds,
                sets: config.sets,
                restBetweenSets: config.restBetweenSets
            )
        }

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

        // Cancel scheduled wake-up notifications
        BackgroundUpdateScheduler.shared.cancelAllWakeUps()

        // Reset state
        state = .idle
        currentRound = 1
        currentSet = 1
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

        // Force update Live Activity with current state after sync
        // This ensures the countdown shows correctly after returning from background
        if #available(iOS 16.1, *) {
            Task {
                await liveActivityManager?.updateLiveActivity(
                    currentState: state,
                    currentRound: currentRound,
                    totalRounds: totalRounds,
                    intervalEndDate: timerEngine.intervalEndDate ?? Date(),
                    isPaused: state == .paused
                )
            }
        }

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
        let totalDuration: TimeInterval
        switch state {
        case .work:
            totalDuration = TimeInterval(config.workTime)
        case .rest:
            totalDuration = TimeInterval(config.restTime)
        case .restBetweenSets:
            totalDuration = TimeInterval(config.restBetweenSets)
        default:
            totalDuration = 0
        }
        progress = timerEngine.progress(totalDuration: totalDuration)

        // Check for state transitions
        if timerEngine.hasIntervalEnded() {
            advanceToNextInterval()
        }
    }

    /// Advance to the next interval (Work → Rest → Work, etc.)
    private func advanceToNextInterval() {
        guard let config = config else { return }

        switch state {
        case .work:
            // Work → Rest
            if config.restTime > 0 {
                state = .rest
                stateBeforePause = .rest
                timerEngine.startInterval(duration: TimeInterval(config.restTime))
                audioManager.playBeep(.restStart)
            } else {
                // No rest period, go to next round or check for set completion
                if currentRound < config.rounds {
                    currentRound += 1
                    state = .work
                    stateBeforePause = .work
                    timerEngine.startInterval(duration: TimeInterval(config.workTime))
                    audioManager.playBeep(.workStart)
                } else {
                    // Last round of set completed, check for next set
                    if currentSet < config.sets {
                        if config.restBetweenSets > 0 {
                            state = .restBetweenSets
                            stateBeforePause = .restBetweenSets
                            timerEngine.startInterval(duration: TimeInterval(config.restBetweenSets))
                            audioManager.playBeep(.restStart)
                        } else {
                            // No rest between sets, start next set immediately
                            currentSet += 1
                            currentRound = 1
                            state = .work
                            stateBeforePause = .work
                            timerEngine.startInterval(duration: TimeInterval(config.workTime))
                            audioManager.playBeep(.workStart)
                        }
                    } else {
                        // All sets completed
                        completeWorkout()
                        return
                    }
                }
            }

        case .rest:
            // Rest → Work (next round) or check for set completion
            if currentRound < config.rounds {
                // More rounds in this set
                currentRound += 1
                state = .work
                stateBeforePause = .work
                timerEngine.startInterval(duration: TimeInterval(config.workTime))
                audioManager.playBeep(.workStart)
            } else {
                // Last round of set completed, check for next set
                if currentSet < config.sets {
                    if config.restBetweenSets > 0 {
                        state = .restBetweenSets
                        stateBeforePause = .restBetweenSets
                        timerEngine.startInterval(duration: TimeInterval(config.restBetweenSets))
                        audioManager.playBeep(.restStart)
                    } else {
                        // No rest between sets, start next set immediately
                        currentSet += 1
                        currentRound = 1
                        state = .work
                        stateBeforePause = .work
                        timerEngine.startInterval(duration: TimeInterval(config.workTime))
                        audioManager.playBeep(.workStart)
                    }
                } else {
                    // All sets completed
                    completeWorkout()
                    return
                }
            }

        case .restBetweenSets:
            // Transition to first round of next set
            currentSet += 1
            currentRound = 1
            state = .work
            stateBeforePause = .work
            timerEngine.startInterval(duration: TimeInterval(config.workTime))
            audioManager.playBeep(.workStart)

        default:
            break
        }

        // Update Live Activity with new state
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

    /// Complete the workout
    private func completeWorkout() {
        state = .finished
        uiUpdateTimer?.cancel()
        timeRemaining = 0
        progress = 1.0

        // Cancel any remaining scheduled notifications
        BackgroundUpdateScheduler.shared.cancelAllWakeUps()

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

    /// Setup observer for pause/resume from Live Activity via App Groups
    private func setupPauseResumeObserver() {
        // Subscribe to SharedDataManager's pause/resume publisher
        // This uses App Groups for cross-process communication from widget extension
        pauseResumeObserver = SharedDataManager.shared.pauseResumePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else {
                    print("TimerViewModel: Pause/Resume received but self is nil")
                    return
                }
                print("TimerViewModel: Pause/Resume command received - current state: \(self.state), canPause: \(self.state.canPause), canResume: \(self.state.canResume)")
                if self.state.canPause {
                    print("TimerViewModel: Calling pause()")
                    self.pause()
                } else if self.state.canResume {
                    print("TimerViewModel: Calling resume()")
                    self.resume()
                } else {
                    print("TimerViewModel: Cannot pause or resume in current state")
                }
            }
    }

    /// Start observing for commands from widget extension
    /// Call this when the timer view appears
    func startObservingWidgetCommands() {
        SharedDataManager.shared.startObserving()
    }

    /// Stop observing for commands from widget extension
    /// Call this when the timer view disappears
    func stopObservingWidgetCommands() {
        SharedDataManager.shared.stopObserving()
    }

    /// Check for pending commands from widget extension
    /// Call this when the app becomes active to catch commands from while suspended
    func checkPendingWidgetCommands() {
        SharedDataManager.shared.checkPendingCommands()
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

