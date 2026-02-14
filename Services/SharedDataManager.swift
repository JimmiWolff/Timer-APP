//
//  SharedDataManager.swift
//  CircuitTimer
//
//  Manages shared data between main app and widget extension via App Groups
//

import Foundation
import Combine

/// Manages shared data between main app and widget extension
///
/// Uses App Groups UserDefaults for cross-process communication.
/// The widget extension writes commands, and the main app observes and executes them.
class SharedDataManager: ObservableObject {
    // MARK: - Singleton

    static let shared = SharedDataManager()

    // MARK: - Constants

    /// App Group identifier - must match entitlements
    static let appGroupIdentifier = "group.wolff.circuittimer"

    /// Key for pause/resume toggle command
    private static let pauseResumeToggleKey = "pauseResumeToggle"

    /// Key for last command timestamp (to detect changes)
    private static let lastCommandTimestampKey = "lastCommandTimestamp"

    /// Key for stop command
    private static let stopCommandKey = "stopCommand"

    /// Key for last stop command timestamp (to detect changes)
    private static let lastStopCommandTimestampKey = "lastStopCommandTimestamp"

    // MARK: - Properties

    /// Shared UserDefaults for App Group
    private let sharedDefaults: UserDefaults?

    /// Publisher for pause/resume commands
    let pauseResumePublisher = PassthroughSubject<Void, Never>()

    /// Publisher for stop commands
    let stopPublisher = PassthroughSubject<Void, Never>()

    /// Timer for polling shared defaults (widget extensions can't use Darwin notifications reliably)
    private var pollingTimer: Timer?

    /// Last processed timestamp to detect new commands
    private var lastProcessedTimestamp: TimeInterval = 0

    /// Last processed stop command timestamp to detect new commands
    private var lastProcessedStopTimestamp: TimeInterval = 0

    // MARK: - Initialization

    private init() {
        sharedDefaults = UserDefaults(suiteName: Self.appGroupIdentifier)

        if sharedDefaults == nil {
            print("SharedDataManager: WARNING - Could not access App Group. Ensure App Groups capability is configured.")
        }

        // Initialize last processed timestamps
        lastProcessedTimestamp = sharedDefaults?.double(forKey: Self.lastCommandTimestampKey) ?? 0
        lastProcessedStopTimestamp = sharedDefaults?.double(forKey: Self.lastStopCommandTimestampKey) ?? 0
    }

    // MARK: - Widget Extension Methods (Write)

    /// Request pause/resume toggle from widget extension
    /// Called by PauseResumeIntent in the widget extension
    func requestPauseResumeToggle() {
        guard let defaults = sharedDefaults else {
            print("SharedDataManager: Cannot write - App Group not available")
            return
        }

        // Write new timestamp to signal a command
        let timestamp = Date().timeIntervalSince1970
        defaults.set(timestamp, forKey: Self.lastCommandTimestampKey)
        defaults.set(true, forKey: Self.pauseResumeToggleKey)
        defaults.synchronize()

        print("SharedDataManager: Pause/Resume toggle requested at \(timestamp)")
    }

    // MARK: - Main App Methods (Read/Observe)

    /// Start observing for commands from widget extension
    /// Call this when the timer view appears
    func startObserving() {
        guard pollingTimer == nil else {
            print("SharedDataManager: Already observing")
            return
        }

        // Immediately check for any pending commands that arrived while suspended
        checkForCommands()

        // Poll every 0.5 seconds for new commands
        // We use polling because Darwin notifications aren't reliable for widget extensions
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForCommands()
        }

        print("SharedDataManager: Started observing for commands")
    }

    /// Stop observing for commands
    func stopObserving() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        print("SharedDataManager: Stopped observing for commands")
    }

    /// Check for pending commands immediately
    /// Call this when the app becomes active to catch commands from while suspended
    func checkPendingCommands() {
        print("SharedDataManager: Checking for pending commands...")
        checkForCommands()
    }

    /// Check for new commands from widget extension
    private func checkForCommands() {
        guard let defaults = sharedDefaults else {
            print("SharedDataManager: Cannot check - App Group not available")
            return
        }

        // Force sync to get latest values from disk
        defaults.synchronize()

        let currentTimestamp = defaults.double(forKey: Self.lastCommandTimestampKey)
        let hasPendingCommand = defaults.bool(forKey: Self.pauseResumeToggleKey)

        print("SharedDataManager: Check - timestamp=\(currentTimestamp), lastProcessed=\(lastProcessedTimestamp), pending=\(hasPendingCommand)")

        // Check if there's a new pause/resume command (timestamp changed AND flag is set)
        if currentTimestamp > lastProcessedTimestamp && hasPendingCommand {
            lastProcessedTimestamp = currentTimestamp

            // Clear the flag
            defaults.set(false, forKey: Self.pauseResumeToggleKey)
            defaults.synchronize()

            // Notify observers
            print("SharedDataManager: Processing pause/resume command!")
            pauseResumePublisher.send()
        }

        // Check for stop commands
        let stopTimestamp = defaults.double(forKey: Self.lastStopCommandTimestampKey)
        let hasPendingStopCommand = defaults.bool(forKey: Self.stopCommandKey)

        print("SharedDataManager: Check stop - timestamp=\(stopTimestamp), lastProcessed=\(lastProcessedStopTimestamp), pending=\(hasPendingStopCommand)")

        // Check if there's a new stop command (timestamp changed AND flag is set)
        if stopTimestamp > lastProcessedStopTimestamp && hasPendingStopCommand {
            lastProcessedStopTimestamp = stopTimestamp

            // Clear the flag
            defaults.set(false, forKey: Self.stopCommandKey)
            defaults.synchronize()

            // Notify observers
            print("SharedDataManager: Processing stop command!")
            stopPublisher.send()
        }
    }

    // MARK: - Cleanup

    deinit {
        stopObserving()
    }
}
