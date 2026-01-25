//
//  ViewModifiers.swift
//  CircuitTimer
//
//  Glassmorphism view modifiers for consistent styling
//

import SwiftUI

// MARK: - Glass Card Modifier

/// Applies glassmorphic styling to any view
struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(Constants.Glass.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Glass.cornerRadius)
                    .stroke(Color.white.opacity(Constants.Glass.borderOpacity), lineWidth: 1)
            )
            .shadow(
                color: Constants.Glass.shadowColor,
                radius: Constants.Glass.shadowRadius,
                x: 0,
                y: Constants.Glass.shadowY
            )
    }
}

// MARK: - Pulse Animation Modifier

/// Applies pulse animation effect for active states
struct PulseAnimationModifier: ViewModifier {
    let isActive: Bool
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive && isPulsing ? 1.05 : 1.0)
            .animation(
                isActive
                    ? .easeInOut(duration: Constants.Animation.pulse)
                        .repeatForever(autoreverses: true)
                    : .default,
                value: isPulsing
            )
            .onAppear {
                if isActive {
                    isPulsing = true
                }
            }
            .onChange(of: isActive) {
                isPulsing = isActive
            }
    }
}

// MARK: - State Background Modifier

/// Applies dynamic gradient background based on timer state
struct StateBackgroundModifier: ViewModifier {
    let state: TimerState

    func body(content: Content) -> some View {
        ZStack {
            Constants.Gradients.gradient(for: state)
                .ignoresSafeArea()

            content
        }
        .animation(.easeInOut(duration: Constants.Animation.backgroundTransition), value: state)
    }
}

// MARK: - Glass Button Modifier

/// Applies glassmorphic button styling
struct GlassButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding(.horizontal, Constants.Layout.buttonPaddingH)
            .padding(.vertical, Constants.Layout.buttonPaddingV)
            .background(.ultraThinMaterial)
            .cornerRadius(Constants.Glass.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Glass.cornerRadius)
                    .stroke(Color.white.opacity(Constants.Glass.borderOpacity), lineWidth: 1)
            )
            .shadow(
                color: Constants.Glass.shadowColor,
                radius: Constants.Glass.shadowRadius,
                x: 0,
                y: Constants.Glass.shadowY
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply glassmorphic card styling
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }

    /// Apply pulse animation effect
    /// - Parameter isActive: Whether the pulse animation should be active
    func pulseAnimation(isActive: Bool) -> some View {
        modifier(PulseAnimationModifier(isActive: isActive))
    }

    /// Apply state-based gradient background
    /// - Parameter state: The current timer state
    func stateBackground(_ state: TimerState) -> some View {
        modifier(StateBackgroundModifier(state: state))
    }

    /// Apply glassmorphic button styling
    func glassButton() -> some View {
        modifier(GlassButtonModifier())
    }
}
