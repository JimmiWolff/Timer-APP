//
//  StopIntent.swift
//  CircuitTimerLiveActivity
//
//  App Intent for stop button on Live Activity
//

import AppIntents
import Foundation

/// App Intent for stop button on Live Activity
@available(iOS 16.1, *)
struct StopIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Timer"

    static var description: IntentDescription =
        IntentDescription("Stops the circuit training timer")

    /// App Group identifier - must match entitlements and SharedDataManager
    private static let appGroupIdentifier = "group.wolff.circuittimer"
    private static let lastStopCommandTimestampKey = "lastStopCommandTimestamp"
    private static let stopCommandKey = "stopCommand"

    /// Perform the intent
    func perform() async throws -> some IntentResult {
        // Write to shared UserDefaults for cross-process communication
        // The main app polls this and will respond to the command
        guard let sharedDefaults = UserDefaults(suiteName: Self.appGroupIdentifier) else {
            print("StopIntent: Could not access App Group")
            return .result()
        }

        // Write timestamp and command flag
        let timestamp = Date().timeIntervalSince1970
        sharedDefaults.set(timestamp, forKey: Self.lastStopCommandTimestampKey)
        sharedDefaults.set(true, forKey: Self.stopCommandKey)
        sharedDefaults.synchronize()

        print("StopIntent: Stop requested at \(timestamp)")

        return .result()
    }
}
