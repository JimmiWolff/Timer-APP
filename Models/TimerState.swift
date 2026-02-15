//
//  TimerState.swift
//  CircuitTimer
//
//  State machine for timer lifecycle
//

import Foundation

/// Timer state machine
enum TimerState: String, Codable, Hashable {
    /// Timer is idle, not started
    case idle

    /// Countdown before first work interval ("Get Ready")
    case countdown

    /// Work interval is active
    case work

    /// Rest interval is active
    case rest

    /// Rest between sets is active
    case restBetweenSets

    /// Timer is paused (can resume to work or rest)
    case paused

    /// Workout is complete
    case finished

    /// Display name for the state
    var displayName: String {
        switch self {
        case .idle:
            return "Ready"
        case .countdown:
            return "GET READY"
        case .work:
            return "WORK"
        case .rest:
            return "REST"
        case .restBetweenSets:
            return "REST BETWEEN SETS"
        case .paused:
            return "PAUSED"
        case .finished:
            return "COMPLETE"
        }
    }

    /// Whether the timer is currently running
    var isActive: Bool {
        return self == .countdown || self == .work || self == .rest || self == .restBetweenSets
    }

    /// Whether the timer can be paused
    var canPause: Bool {
        return self == .countdown || self == .work || self == .rest || self == .restBetweenSets
    }

    /// Whether the timer can be resumed
    var canResume: Bool {
        return self == .paused
    }

    /// Whether the timer can be reset
    var canReset: Bool {
        return self != .idle
    }
}
