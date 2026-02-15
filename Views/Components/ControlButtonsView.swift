//
//  ControlButtonsView.swift
//  CircuitTimer
//
//  Control buttons (Start/Pause/Resume/Reset)
//

import SwiftUI

/// Control buttons for timer (state-dependent)
struct ControlButtonsView: View {
    /// Current timer state
    let state: TimerState

    /// Start button action
    let onStart: () -> Void

    /// Pause button action
    let onPause: () -> Void

    /// Resume button action
    let onResume: () -> Void

    /// Reset button action
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: Constants.Layout.spacing * 1.5) {
            switch state {
            case .idle:
                // Show start button
                ControlButton(
                    icon: "play.fill",
                    action: onStart,
                    accessibilityLabel: "Start workout",
                    accessibilityIdentifier: Constants.Accessibility.startButton
                )

            case .paused:
                // Show resume and reset buttons
                ControlButton(
                    icon: "play.fill",
                    action: onResume,
                    accessibilityLabel: "Resume workout",
                    accessibilityIdentifier: Constants.Accessibility.resumeButton
                )

                ControlButton(
                    icon: "stop.fill",
                    action: onReset,
                    accessibilityLabel: "Stop workout",
                    accessibilityIdentifier: Constants.Accessibility.resetButton
                )

            case .countdown, .work, .rest, .restBetweenSets:
                // Show pause button
                ControlButton(
                    icon: "pause.fill",
                    action: onPause,
                    accessibilityLabel: "Pause workout",
                    accessibilityIdentifier: Constants.Accessibility.pauseButton
                )

            case .finished:
                // Show done button
                ControlButton(
                    label: "Done",
                    action: onReset,
                    accessibilityLabel: "Finish and return",
                    accessibilityIdentifier: Constants.Accessibility.resetButton
                )
            }
        }
    }
}

// MARK: - Individual Control Button
struct ControlButton: View {
    var icon: String?
    var label: String?
    let action: () -> Void
    var accessibilityLabel: String
    var accessibilityIdentifier: String?

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Constants.Layout.buttonIconSize, weight: .semibold))
                }
                if let label = label {
                    Text(label)
                        .font(.system(
                            size: Constants.FontSize.buttonLabel,
                            weight: .semibold
                        ))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, Constants.Layout.buttonPaddingH)
            .padding(.vertical, Constants.Layout.buttonPaddingV)
        }
        .glassButton()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

// MARK: - Preview
#Preview("ControlButtonsView") {
    VStack(spacing: 40) {
        // Idle state
        ControlButtonsView(
            state: .idle,
            onStart: {},
            onPause: {},
            onResume: {},
            onReset: {}
        )

        // Work state
        ControlButtonsView(
            state: .work,
            onStart: {},
            onPause: {},
            onResume: {},
            onReset: {}
        )

        // Paused state
        ControlButtonsView(
            state: .paused,
            onStart: {},
            onPause: {},
            onResume: {},
            onReset: {}
        )

        // Finished state
        ControlButtonsView(
            state: .finished,
            onStart: {},
            onPause: {},
            onResume: {},
            onReset: {}
        )
    }
    .padding()
    .background(Color.green)
}
