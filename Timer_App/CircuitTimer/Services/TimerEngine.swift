//
//  TimerEngine.swift
//  CircuitTimer
//
//  Core date-based timer logic that survives iOS background suspension
//

import Foundation

/// Timer engine using date-based calculations for background safety
///
/// This class implements a date-based timer that remains accurate even when
/// the app is suspended by iOS. Instead of counting down, it stores a target
/// end date and calculates remaining time on demand.
class TimerEngine {
    // MARK: - Properties

    /// Target end date for the current interval (nil when not running)
    private(set) var intervalEndDate: Date?

    /// Time remaining when paused (in seconds)
    private var pausedTimeRemaining: TimeInterval = 0

    /// Whether the timer is currently running
    var isRunning: Bool {
        return intervalEndDate != nil
    }

    /// Whether the timer is currently paused
    var isPaused: Bool {
        return !isRunning && pausedTimeRemaining > 0
    }

    // MARK: - Public Methods

    /// Start a new interval with the specified duration
    /// - Parameter duration: Interval duration in seconds
    func startInterval(duration: TimeInterval) {
        guard duration > 0 else { return }
        intervalEndDate = Date().addingTimeInterval(duration)
        pausedTimeRemaining = 0
    }

    /// Get the time remaining in the current interval
    /// - Returns: Time remaining in seconds (0 if not running)
    func timeRemaining() -> TimeInterval {
        if let endDate = intervalEndDate {
            let remaining = endDate.timeIntervalSinceNow
            return max(0, remaining)
        } else if pausedTimeRemaining > 0 {
            return pausedTimeRemaining
        }
        return 0
    }

    /// Check if the current interval has ended
    /// - Returns: True if the interval end date has passed
    func hasIntervalEnded() -> Bool {
        guard let endDate = intervalEndDate else { return false }
        return Date() >= endDate
    }

    /// Pause the timer, storing remaining time
    func pause() {
        guard let endDate = intervalEndDate else { return }
        pausedTimeRemaining = max(0, endDate.timeIntervalSinceNow)
        intervalEndDate = nil
    }

    /// Resume the timer from paused state
    func resume() {
        guard pausedTimeRemaining > 0 else { return }
        intervalEndDate = Date().addingTimeInterval(pausedTimeRemaining)
        pausedTimeRemaining = 0
    }

    /// Reset the timer to initial state
    func reset() {
        intervalEndDate = nil
        pausedTimeRemaining = 0
    }

    /// Get the progress percentage of the current interval
    /// - Parameter totalDuration: Total duration of the interval
    /// - Returns: Progress from 0.0 (start) to 1.0 (end)
    func progress(totalDuration: TimeInterval) -> Double {
        guard totalDuration > 0 else { return 0 }
        let remaining = timeRemaining()
        let elapsed = totalDuration - remaining
        return min(1.0, max(0.0, elapsed / totalDuration))
    }

    /// Calculate how much time has passed since interval started
    /// - Parameter totalDuration: Total duration of the interval
    /// - Returns: Elapsed time in seconds
    func elapsedTime(totalDuration: TimeInterval) -> TimeInterval {
        let remaining = timeRemaining()
        return totalDuration - remaining
    }
}

// MARK: - Debug Description
extension TimerEngine: CustomDebugStringConvertible {
    var debugDescription: String {
        if let endDate = intervalEndDate {
            return "TimerEngine(endDate: \(endDate), remaining: \(timeRemaining())s)"
        } else if pausedTimeRemaining > 0 {
            return "TimerEngine(paused: \(pausedTimeRemaining)s)"
        } else {
            return "TimerEngine(idle)"
        }
    }
}
