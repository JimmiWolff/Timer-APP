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

    /// App Group identifier - must match entitlements and SharedDataManager
    private static let appGroupIdentifier = "group.wolff.circuittimer"
    private static let lastCommandTimestampKey = "lastCommandTimestamp"
    private static let pauseResumeToggleKey = "pauseResumeToggle"

    /// Perform the intent
    func perform() async throws -> some IntentResult {
        // Write to shared UserDefaults for cross-process communication
        // The main app polls this and will respond to the command
        guard let sharedDefaults = UserDefaults(suiteName: Self.appGroupIdentifier) else {
            print("PauseResumeIntent: Could not access App Group")
            return .result()
        }

        // Write timestamp and toggle flag
        let timestamp = Date().timeIntervalSince1970
        sharedDefaults.set(timestamp, forKey: Self.lastCommandTimestampKey)
        sharedDefaults.set(true, forKey: Self.pauseResumeToggleKey)
        sharedDefaults.synchronize()

        print("PauseResumeIntent: Pause/Resume requested at \(timestamp)")

        return .result()
    }
}
