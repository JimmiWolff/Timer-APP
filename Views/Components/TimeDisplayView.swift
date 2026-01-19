//
//  TimeDisplayView.swift
//  CircuitTimer
//
//  Large time display component
//

import SwiftUI

/// Large time display showing remaining time
struct TimeDisplayView: View {
    /// Time remaining in seconds
    let timeRemaining: TimeInterval

    /// Text color
    var color: Color = .white

    var body: some View {
        Text(formattedTime)
            .font(.system(
                size: Constants.FontSize.largeTime,
                weight: .bold,
                design: .rounded
            ))
            .monospacedDigit()
            .foregroundColor(color)
            .accessibilityLabel("Time remaining: \(formattedTime)")
            .accessibilityIdentifier(Constants.Accessibility.timeDisplay)
    }

    /// Format time as MM:SS
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#Preview("TimeDisplayView") {
    VStack(spacing: 40) {
        TimeDisplayView(timeRemaining: 0)

        TimeDisplayView(timeRemaining: 45)

        TimeDisplayView(timeRemaining: 90)

        TimeDisplayView(timeRemaining: 3599)
    }
    .padding()
    .background(Color.green)
}
