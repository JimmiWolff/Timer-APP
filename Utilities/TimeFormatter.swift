//
//  TimeFormatter.swift
//  CircuitTimer
//
//  Utility for formatting time intervals
//

import Foundation

/// Utility for formatting time intervals
enum TimeFormatter {
    /// Format time interval as MM:SS
    /// - Parameter interval: Time interval in seconds
    /// - Returns: Formatted string (e.g., "02:45")
    static func formatMMSS(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Format time interval as HH:MM:SS
    /// - Parameter interval: Time interval in seconds
    /// - Returns: Formatted string (e.g., "01:23:45")
    static func formatHHMMSS(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Format time interval as compact string (e.g., "2m 30s")
    /// - Parameter interval: Time interval in seconds
    /// - Returns: Compact formatted string
    static func formatCompact(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)

        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        } else if totalSeconds < 3600 {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            if seconds == 0 {
                return "\(minutes)m"
            } else {
                return "\(minutes)m \(seconds)s"
            }
        } else {
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)m"
            }
        }
    }

    /// Format time interval for speech (e.g., "2 minutes and 30 seconds")
    /// - Parameter interval: Time interval in seconds
    /// - Returns: Speech-friendly formatted string
    static func formatSpeech(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes == 0 {
            return seconds == 1 ? "1 second" : "\(seconds) seconds"
        } else if seconds == 0 {
            return minutes == 1 ? "1 minute" : "\(minutes) minutes"
        } else {
            let minuteStr = minutes == 1 ? "1 minute" : "\(minutes) minutes"
            let secondStr = seconds == 1 ? "1 second" : "\(seconds) seconds"
            return "\(minuteStr) and \(secondStr)"
        }
    }
}

// MARK: - TimeInterval Extension
extension TimeInterval {
    /// Format as MM:SS
    var asMMSS: String {
        TimeFormatter.formatMMSS(self)
    }

    /// Format as HH:MM:SS
    var asHHMMSS: String {
        TimeFormatter.formatHHMMSS(self)
    }

    /// Format compactly
    var asCompact: String {
        TimeFormatter.formatCompact(self)
    }

    /// Format for speech
    var asSpeech: String {
        TimeFormatter.formatSpeech(self)
    }
}
