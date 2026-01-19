//
//  PauseResumeIntent.swift
//  CircuitTimerLiveActivity
//
//  App Intent for pause/resume button on Live Activity
//

import AppIntents
import Foundation

/// App Intent for pause/resume button on Live Activity
@available(iOS 16.1, *)
struct PauseResumeIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause or Resume Timer"

    static var description: IntentDescription =
        IntentDescription("Pauses or resumes the circuit training timer")

    /// Perform the intent
    func perform() async throws -> some IntentResult {
        // Post notification to main app to handle pause/resume
        NotificationCenter.default.post(
            name: .pauseResumeTimer,
            object: nil
        )

        return .result()
    }
}

// MARK: - Notification Name Extension
extension Notification.Name {
    /// Notification posted when pause/resume button tapped on Live Activity
    static let pauseResumeTimer = Notification.Name("pauseResumeTimer")
}
