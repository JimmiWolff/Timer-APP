//
//  Constants.swift
//  CircuitTimer
//
//  App-wide constants
//

import SwiftUI

/// App-wide constants
enum Constants {
    // MARK: - Colors

    /// Colors for timer states
    enum Colors {
        /// Work interval color (energetic green)
        static let work = Color(red: 0.2, green: 0.8, blue: 0.3)

        /// Rest interval color (calming red)
        static let rest = Color(red: 0.9, green: 0.3, blue: 0.2)

        /// Paused state color (warning orange)
        static let paused = Color(red: 1.0, green: 0.6, blue: 0.0)

        /// Finished state color (success blue)
        static let finished = Color(red: 0.0, green: 0.5, blue: 1.0)

        /// Idle state color (neutral gray)
        static let idle = Color.gray

        /// Background color for setup screen
        static let background = Color(UIColor.systemBackground)

        /// Secondary background
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    }

    // MARK: - Typography

    /// Font sizes
    enum FontSize {
        /// Large time display
        static let largeTime: CGFloat = 72

        /// Medium state text
        static let mediumState: CGFloat = 32

        /// Round indicator
        static let roundIndicator: CGFloat = 24

        /// Button label
        static let buttonLabel: CGFloat = 20

        /// Small helper text
        static let helperText: CGFloat = 14
    }

    // MARK: - Layout

    /// Layout dimensions
    enum Layout {
        /// Progress circle diameter
        static let progressCircleSize: CGFloat = 280

        /// Progress circle line width
        static let progressLineWidth: CGFloat = 20

        /// Control button size
        static let buttonSize: CGFloat = 80

        /// Control button icon size
        static let buttonIconSize: CGFloat = 40

        /// Standard spacing
        static let spacing: CGFloat = 20

        /// Large spacing
        static let largeSpacing: CGFloat = 40

        /// Corner radius
        static let cornerRadius: CGFloat = 16
    }

    // MARK: - Animation

    /// Animation durations
    enum Animation {
        /// Quick animation
        static let quick: Double = 0.2

        /// Standard animation
        static let standard: Double = 0.3

        /// Slow animation
        static let slow: Double = 0.5
    }

    // MARK: - Timer

    /// Timer configuration limits
    enum TimerLimits {
        /// Minimum interval duration (seconds)
        static let minInterval: Int = 1

        /// Maximum interval duration (seconds)
        static let maxInterval: Int = 3600 // 1 hour

        /// Minimum rounds
        static let minRounds: Int = 1

        /// Maximum rounds
        static let maxRounds: Int = 50

        /// UI update interval (seconds)
        static let uiUpdateInterval: TimeInterval = 0.1
    }

    // MARK: - Audio

    /// Audio configuration
    enum Audio {
        /// Duration to keep audio session active after beep (seconds)
        static let sessionActiveDelay: TimeInterval = 0.5

        /// Default beep volume
        static let defaultVolume: Float = 0.7
    }

    // MARK: - Live Activities

    /// Live Activity configuration
    enum LiveActivity {
        /// Dismissal delay after workout complete (seconds)
        static let dismissalDelay: TimeInterval = 10

        /// Maximum Live Activity duration (seconds)
        static let maxDuration: TimeInterval = 28800 // 8 hours
    }

    // MARK: - Accessibility

    /// Accessibility identifiers
    enum Accessibility {
        static let setupView = "setupView"
        static let timerView = "timerView"
        static let startButton = "startButton"
        static let pauseButton = "pauseButton"
        static let resumeButton = "resumeButton"
        static let resetButton = "resetButton"
        static let timeDisplay = "timeDisplay"
        static let stateLabel = "stateLabel"
        static let roundLabel = "roundLabel"
    }
}

// MARK: - Color Extension for State
extension Color {
    /// Get color for timer state
    /// - Parameter state: Timer state
    /// - Returns: Color for that state
    static func forState(_ state: TimerState) -> Color {
        switch state {
        case .idle:
            return Constants.Colors.idle
        case .work:
            return Constants.Colors.work
        case .rest:
            return Constants.Colors.rest
        case .paused:
            return Constants.Colors.paused
        case .finished:
            return Constants.Colors.finished
        }
    }
}
