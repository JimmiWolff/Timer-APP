//
//  StateBadgeView.swift
//  CircuitTimer
//
//  State badge with glassmorphic styling and pulse animation
//

import SwiftUI

/// State badge showing current timer state with pulse animation
struct StateBadgeView: View {
    let state: TimerState

    var body: some View {
        Text(state.displayName)
            .font(.system(size: Constants.FontSize.stateBadge, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .glassCard()
            .pulseAnimation(isActive: shouldPulse)
    }

    /// Whether the badge should pulse (active states only)
    private var shouldPulse: Bool {
        state == .work || state == .rest || state == .restBetweenSets
    }
}

// MARK: - Preview
#Preview("State Badge - Work") {
    ZStack {
        Constants.Gradients.work
            .ignoresSafeArea()

        StateBadgeView(state: .work)
    }
}

#Preview("State Badge - Rest") {
    ZStack {
        Constants.Gradients.rest
            .ignoresSafeArea()

        StateBadgeView(state: .rest)
    }
}

#Preview("State Badge - Paused") {
    ZStack {
        Constants.Gradients.work
            .ignoresSafeArea()

        StateBadgeView(state: .paused)
    }
}
