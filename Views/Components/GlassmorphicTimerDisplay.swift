//
//  GlassmorphicTimerDisplay.swift
//  CircuitTimer
//
//  Integrated timer display with circular progress and indicators
//

import SwiftUI

/// Glassmorphic timer display component combining progress ring, time, and indicators
struct GlassmorphicTimerDisplay: View {
    let timeRemaining: TimeInterval
    let progress: Double
    let state: TimerState
    let currentRound: Int
    let totalRounds: Int
    let currentSet: Int
    let totalSets: Int

    var body: some View {
        ZStack {
            // Circular progress ring
            CircularProgressView(
                progress: progress,
                color: .white,
                lineWidth: Constants.Layout.progressLineWidth
            )
            .frame(
                width: Constants.Layout.progressCircleSize,
                height: Constants.Layout.progressCircleSize
            )

            // Timer content
            VStack(spacing: 12) {
                // Time display
                Text(formattedTime)
                    .font(.system(size: Constants.FontSize.extraLargeTime, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .accessibilityLabel("Time remaining: \(formattedTime)")
                    .accessibilityIdentifier(Constants.Accessibility.timeDisplay)

                // Indicators (if not idle/finished)
                if showIndicators {
                    VStack(spacing: 4) {
                        // Set indicator (only if multiple sets)
                        if totalSets > 1 {
                            Text("Set \(currentSet) / \(totalSets)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.95))
                                .accessibilityLabel("Set \(currentSet) of \(totalSets)")
                        }

                        // Round indicator (hide during rest between sets)
                        if state != .restBetweenSets {
                            Text("Round \(currentRound) / \(totalRounds)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .accessibilityLabel("Round \(currentRound) of \(totalRounds)")
                                .accessibilityIdentifier(Constants.Accessibility.roundLabel)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Computed Properties

    /// Whether to show set/round indicators
    private var showIndicators: Bool {
        state != .idle && state != .finished
    }

    /// Formatted time string (MM:SS)
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#Preview("Timer Display - Work") {
    ZStack {
        Constants.Gradients.work
            .ignoresSafeArea()

        GlassmorphicTimerDisplay(
            timeRemaining: 45,
            progress: 0.6,
            state: .work,
            currentRound: 3,
            totalRounds: 8,
            currentSet: 1,
            totalSets: 3
        )
    }
}

#Preview("Timer Display - Rest") {
    ZStack {
        Constants.Gradients.rest
            .ignoresSafeArea()

        GlassmorphicTimerDisplay(
            timeRemaining: 10,
            progress: 0.3,
            state: .rest,
            currentRound: 3,
            totalRounds: 8,
            currentSet: 1,
            totalSets: 3
        )
    }
}

#Preview("Timer Display - Idle") {
    ZStack {
        Constants.Gradients.idle
            .ignoresSafeArea()

        GlassmorphicTimerDisplay(
            timeRemaining: 0,
            progress: 0,
            state: .idle,
            currentRound: 1,
            totalRounds: 8,
            currentSet: 1,
            totalSets: 1
        )
    }
}
