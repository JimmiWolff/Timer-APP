//
//  CircuitTimerLiveActivity.swift
//  CircuitTimerLiveActivity
//
//  Live Activity widget for Lock Screen and Dynamic Island
//

import ActivityKit
import WidgetKit
import SwiftUI

/// Live Activity widget configuration
@available(iOS 16.1, *)
struct CircuitTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CircuitTimerAttributes.self) { context in
            // Lock Screen UI
            lockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island UI
            dynamicIslandView(context: context)
        }
    }

    // MARK: - Lock Screen View

    /// Lock Screen / Notification Banner view
    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<CircuitTimerAttributes>) -> some View {
        HStack(alignment: .center, spacing: 16) {
            // Left: State and round info
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.currentState)
                    .font(.headline)
                    .foregroundColor(stateColor(context.state.currentState))

                Text("Round \(context.state.currentRound)/\(context.state.totalRounds)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Center: Countdown timer
            Text(context.state.intervalEndDate, style: .timer)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundColor(.primary)

            Spacer()

            // Right: Pause/Resume button
            Button(intent: PauseResumeIntent()) {
                Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .activityBackgroundTint(Color(UIColor.systemBackground))
        .activitySystemActionForegroundColor(.accentColor)
    }

    // MARK: - Dynamic Island Views

    /// Dynamic Island configuration
    private func dynamicIslandView(context: ActivityViewContext<CircuitTimerAttributes>) -> DynamicIsland {
        DynamicIsland {
            // Expanded view (when long-pressed)
            DynamicIslandExpandedRegion(.leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.currentState)
                        .font(.headline)
                        .foregroundColor(stateColor(context.state.currentState))

                    Text("Round \(context.state.currentRound)/\(context.state.totalRounds)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            DynamicIslandExpandedRegion(.trailing) {
                Text(context.state.intervalEndDate, style: .timer)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            DynamicIslandExpandedRegion(.bottom) {
                HStack {
                    // Progress bar
                    ProgressView(value: progressValue(context: context))
                        .tint(stateColor(context.state.currentState))

                    // Pause/Resume button
                    Button(intent: PauseResumeIntent()) {
                        Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }

        } compactLeading: {
            // Compact leading (left pill)
            Image(systemName: iconForState(context.state.currentState))
                .foregroundColor(stateColor(context.state.currentState))

        } compactTrailing: {
            // Compact trailing (right pill)
            Text(context.state.intervalEndDate, style: .timer)
                .font(.caption2)
                .monospacedDigit()
                .frame(width: 40)

        } minimal: {
            // Minimal (when multiple activities)
            Image(systemName: "timer")
                .foregroundColor(.accentColor)
        }
    }

    // MARK: - Helper Methods

    /// Get color for state
    private func stateColor(_ stateName: String) -> Color {
        switch stateName {
        case "WORK":
            return .green
        case "REST":
            return .red
        case "PAUSED":
            return .orange
        case "COMPLETE":
            return .blue
        default:
            return .gray
        }
    }

    /// Get icon for state
    private func iconForState(_ stateName: String) -> String {
        switch stateName {
        case "WORK":
            return "figure.run"
        case "REST":
            return "pause.circle.fill"
        case "PAUSED":
            return "pause.fill"
        case "COMPLETE":
            return "checkmark.circle.fill"
        default:
            return "timer"
        }
    }

    /// Calculate progress value for progress bar
    private func progressValue(context: ActivityViewContext<CircuitTimerAttributes>) -> Double {
        let now = Date()
        let endDate = context.state.intervalEndDate

        let totalDuration: TimeInterval
        if context.state.currentState == "WORK" {
            totalDuration = TimeInterval(context.attributes.workDuration)
        } else {
            totalDuration = TimeInterval(context.attributes.restDuration)
        }

        let remaining = max(0, endDate.timeIntervalSince(now))
        let elapsed = totalDuration - remaining

        return min(1.0, max(0.0, elapsed / totalDuration))
    }
}

// MARK: - Preview
@available(iOS 16.1, *)
#Preview("Lock Screen", as: .content, using: CircuitTimerAttributes(
    workDuration: 30,
    restDuration: 10,
    totalRounds: 8
)) {
    CircuitTimerLiveActivity()
} contentStates: {
    CircuitTimerAttributes.ContentState(
        currentState: "WORK",
        currentRound: 1,
        totalRounds: 8,
        intervalEndDate: Date().addingTimeInterval(25),
        isPaused: false
    )

    CircuitTimerAttributes.ContentState(
        currentState: "REST",
        currentRound: 2,
        totalRounds: 8,
        intervalEndDate: Date().addingTimeInterval(8),
        isPaused: false
    )

    CircuitTimerAttributes.ContentState(
        currentState: "PAUSED",
        currentRound: 3,
        totalRounds: 8,
        intervalEndDate: Date().addingTimeInterval(15),
        isPaused: true
    )
}
