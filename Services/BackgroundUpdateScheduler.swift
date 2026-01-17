//
//  BackgroundUpdateScheduler.swift
//  CircuitTimer
//
//  Schedules background wake-ups for Live Activity updates during state transitions
//

import Foundation
import UserNotifications

/// Schedules notifications to wake the app at state transition times
///
/// This ensures the app wakes up to update Live Activities even when fully suspended.
class BackgroundUpdateScheduler {
    // MARK: - Singleton

    static let shared = BackgroundUpdateScheduler()

    private init() {}

    // MARK: - Public Methods

    /// Schedule wake-up notifications for all workout state transitions
    /// - Parameters:
    ///   - workDuration: Work interval duration in seconds
    ///   - restDuration: Rest interval duration in seconds
    ///   - rounds: Total number of rounds
    func scheduleTransitionWakeUps(
        workDuration: Int,
        restDuration: Int,
        rounds: Int
    ) {
        // Cancel any existing scheduled notifications
        cancelAllWakeUps()

        var scheduledTime: TimeInterval = 0
        var notificationCount = 0

        for round in 1...rounds {
            // Schedule wake-up at end of work interval (Work → Rest transition)
            scheduledTime += TimeInterval(workDuration)
            scheduleWakeUp(
                identifier: "wakeup_\(round)_work_to_rest",
                timeInterval: scheduledTime,
                message: "Round \(round) - Rest"
            )
            notificationCount += 1

            // Schedule wake-up at end of rest interval (Rest → Work transition)
            // Skip for the last round
            if round < rounds {
                scheduledTime += TimeInterval(restDuration)
                scheduleWakeUp(
                    identifier: "wakeup_\(round)_rest_to_work",
                    timeInterval: scheduledTime,
                    message: "Round \(round + 1) - Work"
                )
                notificationCount += 1
            }
        }

        print("BackgroundUpdateScheduler: Scheduled \(notificationCount) wake-up notifications")
    }

    /// Cancel all scheduled wake-up notifications
    func cancelAllWakeUps() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("BackgroundUpdateScheduler: Cancelled all wake-up notifications")
    }

    /// Request notification permissions (call once at app launch)
    static func requestPermissions() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound]
            )

            if granted {
                print("BackgroundUpdateScheduler: Notification permission granted")
            } else {
                print("BackgroundUpdateScheduler: Notification permission denied")
            }

            return granted
        } catch {
            print("BackgroundUpdateScheduler: Failed to request notification permission: \(error)")
            return false
        }
    }

    // MARK: - Private Methods

    /// Schedule a single wake-up notification
    private func scheduleWakeUp(
        identifier: String,
        timeInterval: TimeInterval,
        message: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = "CircuitTimer"
        content.body = message
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        // Trigger notification at specified time
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, timeInterval), // Minimum 1 second
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("BackgroundUpdateScheduler: Failed to schedule '\(identifier)': \(error)")
            } else {
                print("BackgroundUpdateScheduler: Scheduled '\(identifier)' at +\(timeInterval)s")
            }
        }
    }
}
