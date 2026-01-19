//
//  Constants.swift
//  CircuitTimer
//
//  App-wide constants
//

import SwiftUI

/// App-wide constants
enum Constants {
    // MARK: - Gradients

    /// Gradient backgrounds for timer states (glassmorphism design)
    enum Gradients {
        /// Work interval gradient (purple: #667eea → #764ba2)
        static let work = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.496, blue: 0.918),
                Color(red: 0.463, green: 0.294, blue: 0.635)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Rest interval gradient (pink/red: #f093fb → #f5576c)
        static let rest = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.941, green: 0.576, blue: 0.984),
                Color(red: 0.961, green: 0.341, blue: 0.424)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Rest between sets gradient (pink/yellow: #fa709a → #fee140)
        static let restBetweenSets = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.980, green: 0.439, blue: 0.604),
                Color(red: 0.996, green: 0.882, blue: 0.251)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Idle state gradient (blue: #4facfe → #00f2fe)
        static let idle = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.310, green: 0.675, blue: 0.996),
                Color(red: 0.0, green: 0.949, blue: 0.996)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Finished state gradient (green: #43e97b → #38f9d7)
        static let finished = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.263, green: 0.914, blue: 0.482),
                Color(red: 0.220, green: 0.976, blue: 0.843)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        /// Get gradient for a specific timer state
        /// - Parameter state: Timer state
        /// - Returns: LinearGradient for that state
        static func gradient(for state: TimerState) -> LinearGradient {
            switch state {
            case .idle:
                return idle
            case .work:
                return work
            case .rest:
                return rest
            case .restBetweenSets:
                return restBetweenSets
            case .paused:
                return work // Keep current gradient when paused
            case .finished:
                return finished
            }
        }
    }

    // MARK: - Colors (Legacy - kept for compatibility)

    /// Colors for timer states (solid colors for compatibility)
    enum Colors {
        /// Work interval color (energetic green)
        static let work = Color(red: 0.2, green: 0.8, blue: 0.3)

        /// Rest interval color (calming red)
        static let rest = Color(red: 0.9, green: 0.3, blue: 0.2)

        /// Rest between sets color (deeper blue)
        static let restBetweenSets = Color(red: 0.2, green: 0.4, blue: 0.9)

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

    // MARK: - Glassmorphism

    /// Glassmorphism styling constants
    enum Glass {
        /// Glass background opacity
        static let backgroundOpacity: Double = 0.1

        /// Glass border opacity
        static let borderOpacity: Double = 0.2

        /// Blur radius for glass effect
        static let blurRadius: CGFloat = 10

        /// Corner radius for glass cards
        static let cornerRadius: CGFloat = 20

        /// Shadow color for glass cards
        static let shadowColor = Color.black.opacity(0.1)

        /// Shadow radius for glass cards
        static let shadowRadius: CGFloat = 16

        /// Shadow vertical offset
        static let shadowY: CGFloat = 8

        /// Padding inside glass cards
        static let cardPadding: CGFloat = 24
    }

    // MARK: - Typography

    /// Font sizes (updated for glassmorphism design)
    enum FontSize {
        /// Extra large timer display (glassmorphic design)
        static let extraLargeTime: CGFloat = 90

        /// Large time display
        static let largeTime: CGFloat = 72

        /// App title size
        static let appTitle: CGFloat = 48

        /// Timer view title size
        static let timerTitle: CGFloat = 36

        /// State badge text
        static let stateBadge: CGFloat = 28

        /// Medium state text
        static let mediumState: CGFloat = 32

        /// Round indicator
        static let roundIndicator: CGFloat = 24

        /// Button label
        static let buttonLabel: CGFloat = 18

        /// Small helper text
        static let helperText: CGFloat = 14
    }

    // MARK: - Layout

    /// Layout dimensions (updated for glassmorphism design)
    enum Layout {
        /// Progress circle diameter (increased for glassmorphic design)
        static let progressCircleSize: CGFloat = 300

        /// Progress circle line width
        static let progressLineWidth: CGFloat = 12

        /// Control button size
        static let buttonSize: CGFloat = 80

        /// Control button icon size
        static let buttonIconSize: CGFloat = 24

        /// Standard spacing
        static let spacing: CGFloat = 20

        /// Medium spacing
        static let mediumSpacing: CGFloat = 24

        /// Large spacing
        static let largeSpacing: CGFloat = 40

        /// Corner radius
        static let cornerRadius: CGFloat = 16

        /// Button padding horizontal
        static let buttonPaddingH: CGFloat = 32

        /// Button padding vertical
        static let buttonPaddingV: CGFloat = 16
    }

    // MARK: - Animation

    /// Animation durations (updated for glassmorphism design)
    enum Animation {
        /// Quick animation
        static let quick: Double = 0.2

        /// Standard animation
        static let standard: Double = 0.3

        /// Fade in animation
        static let fadeIn: Double = 0.3

        /// Slow animation
        static let slow: Double = 0.5

        /// Background gradient transition (glassmorphic design)
        static let backgroundTransition: Double = 0.6

        /// Pulse animation duration
        static let pulse: Double = 1.0

        /// Progress ring update
        static let progressUpdate: Double = 0.1
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
        case .restBetweenSets:
            return Constants.Colors.restBetweenSets
        case .paused:
            return Constants.Colors.paused
        case .finished:
            return Constants.Colors.finished
        }
    }
}
