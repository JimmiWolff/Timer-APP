//
//  CircuitTimerApp.swift
//  CircuitTimer
//
//  App entry point
//

import SwiftUI
import ActivityKit

/// Main app entry point
@main
struct CircuitTimerApp: App {
    init() {
        // Cancel any leftover notifications from a previous session
        // (handles case where user force-quit the app during a workout)
        BackgroundUpdateScheduler.shared.cancelAllWakeUps()

        // Also end any stale Live Activities
        if #available(iOS 16.1, *) {
            Task {
                await Self.endAllLiveActivities()
            }
        }

        // Request notification permissions for background wake-ups
        Task {
            _ = await BackgroundUpdateScheduler.requestPermissions()
        }
    }

    /// End all Live Activities (cleanup from force-quit)
    @available(iOS 16.1, *)
    private static func endAllLiveActivities() async {
        for activity in Activity<CircuitTimerAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
