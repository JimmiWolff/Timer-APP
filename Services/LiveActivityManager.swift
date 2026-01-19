//
//  LiveActivityManager.swift
//  CircuitTimer
//
//  Manages Live Activities for Lock Screen display
//

import Foundation
import ActivityKit

/// Manages Live Activity lifecycle for workout timer
///
/// This class handles creating, updating, and ending Live Activities that display
/// on the Lock Screen and Dynamic Island during workouts.
@available(iOS 16.1, *)
class LiveActivityManager {
    // MARK: - Properties

    /// Current active Live Activity
    private var activity: Activity<CircuitTimerAttributes>?

    /// Whether Live Activities are supported and authorized
    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    // MARK: - Error Types

    enum LiveActivityError: Error {
        case notAuthorized
        case notSupported
        case failedToStart
        case failedToUpdate
        case alreadyActive
    }

    // MARK: - Public Methods

    /// Start a new Live Activity
    /// - Parameters:
    ///   - config: Timer configuration
    ///   - currentState: Current timer state (work or rest)
    ///   - currentRound: Current round number
    ///   - intervalEndDate: Target end date for current interval
    /// - Throws: LiveActivityError if unable to start
    func startLiveActivity(
        config: TimerConfiguration,
        currentState: TimerState,
        currentRound: Int,
        intervalEndDate: Date
    ) async throws {
        // Check authorization
        guard isSupported else {
            print("LiveActivityManager: Live Activities not authorized")
            throw LiveActivityError.notAuthorized
        }

        // End any existing activity first
        if activity != nil {
            await endLiveActivity()
        }

        // Define attributes (static data)
        let attributes = CircuitTimerAttributes(
            workDuration: config.workTime,
            restDuration: config.restTime,
            totalRounds: config.rounds
        )

        // Define content state (dynamic data)
        let contentState = CircuitTimerAttributes.ContentState(
            currentState: currentState.displayName,
            currentRound: currentRound,
            totalRounds: config.rounds,
            intervalEndDate: intervalEndDate,
            isPaused: false
        )

        do {
            // Request Live Activity (using iOS 16.2+ API for better reliability)
            if #available(iOS 16.2, *) {
                activity = try Activity.request(
                    attributes: attributes,
                    content: ActivityContent(state: contentState, staleDate: nil),
                    pushType: nil
                )
            } else {
                activity = try Activity.request(
                    attributes: attributes,
                    contentState: contentState,
                    pushType: nil
                )
            }

            print("LiveActivityManager: Started Live Activity")
        } catch {
            print("LiveActivityManager: Failed to start Live Activity: \(error.localizedDescription)")
            throw LiveActivityError.failedToStart
        }
    }

    /// Update the existing Live Activity
    /// - Parameters:
    ///   - currentState: Current timer state
    ///   - currentRound: Current round number
    ///   - totalRounds: Total number of rounds
    ///   - intervalEndDate: Target end date for current interval
    ///   - isPaused: Whether timer is paused
    func updateLiveActivity(
        currentState: TimerState,
        currentRound: Int,
        totalRounds: Int,
        intervalEndDate: Date,
        isPaused: Bool
    ) async {
        guard let activity = activity else {
            print("LiveActivityManager: No active Live Activity to update")
            return
        }

        // Create updated content state
        let contentState = CircuitTimerAttributes.ContentState(
            currentState: currentState.displayName,
            currentRound: currentRound,
            totalRounds: totalRounds,
            intervalEndDate: intervalEndDate,
            isPaused: isPaused
        )

        // Update the activity (using iOS 16.2+ API for better reliability)
        if #available(iOS 16.2, *) {
            await activity.update(ActivityContent(state: contentState, staleDate: nil))
        } else {
            await activity.update(using: contentState)
        }

        print("LiveActivityManager: Updated Live Activity")
    }

    /// End the current Live Activity
    /// - Parameter dismissalPolicy: When to dismiss (default: after 10 seconds)
    func endLiveActivity(dismissalPolicy: ActivityUIDismissalPolicy = .after(Date().addingTimeInterval(10))) async {
        guard let activity = activity else {
            print("LiveActivityManager: No active Live Activity to end")
            return
        }

        // End with final content state (using iOS 16.2+ API)
        if #available(iOS 16.2, *) {
            let finalState = activity.content.state
            await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: dismissalPolicy)
        } else {
            let finalState = activity.contentState
            await activity.end(using: finalState, dismissalPolicy: dismissalPolicy)
        }

        self.activity = nil
        print("LiveActivityManager: Ended Live Activity")
    }

    /// Check if there's an active Live Activity
    var hasActiveActivity: Bool {
        return activity != nil
    }

    /// Get the current activity ID
    var activityID: String? {
        return activity?.id
    }
}

// MARK: - Live Activity Attributes

/// Attributes for Circuit Timer Live Activity
/// This struct defines the static and dynamic data displayed in the Live Activity
struct CircuitTimerAttributes: ActivityAttributes {
    /// Content state (dynamic data that changes during workout)
    public struct ContentState: Codable, Hashable {
        /// Current state name (WORK, REST, PAUSED, etc.)
        var currentState: String

        /// Current round number
        var currentRound: Int

        /// Total number of rounds
        var totalRounds: Int

        /// Target end date for current interval
        /// CRITICAL: Widget uses this for auto-countdown with .timer style
        var intervalEndDate: Date

        /// Whether the timer is paused
        var isPaused: Bool
    }

    // MARK: - Static Attributes (don't change during workout)

    /// Work interval duration in seconds
    var workDuration: Int

    /// Rest interval duration in seconds
    var restDuration: Int

    /// Total number of rounds
    var totalRounds: Int
}

// MARK: - Availability Check Helper
extension LiveActivityManager {
    /// Check if Live Activities are available on this device
    static var isAvailable: Bool {
        if #available(iOS 16.1, *) {
            return ActivityAuthorizationInfo().areActivitiesEnabled
        }
        return false
    }
}
