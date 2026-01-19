//
//  CircuitTimerApp.swift
//  CircuitTimer
//
//  App entry point
//

import SwiftUI

/// Main app entry point
@main
struct CircuitTimerApp: App {
    init() {
        // Request notification permissions for background wake-ups
        Task {
            _ = await BackgroundUpdateScheduler.requestPermissions()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
