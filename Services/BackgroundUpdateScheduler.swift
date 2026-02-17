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
    ///   - rounds: Total number of rounds per set
    ///   - sets: Total number of sets
    ///   - restBetweenSets: Rest duration between sets in seconds
    ///   - countdownDuration: Countdown duration before first work interval (seconds)
    func scheduleTransitionWakeUps(
        workDuration: Int,
        restDuration: Int,
        rounds: Int,
        sets: Int = 1,
        restBetweenSets: Int = 0,
        countdownDuration: Int = 0
    ) {
        // Cancel any existing scheduled notifications
        cancelAllWakeUps()

        let startDate = Date()
        // Offset by countdown duration so notifications fire after countdown completes
        var scheduledTime: TimeInterval = TimeInterval(countdownDuration)
        var notificationCount = 0
        var scheduleEntries: [(offset: TimeInterval, wallClock: Date, description: String)] = []

        for set in 1...sets {
            for round in 1...rounds {
                // Schedule wake-up at end of work interval (Work → Rest transition)
                scheduledTime += TimeInterval(workDuration)

                let isLastWorkInterval = (round == rounds && set == sets)
                let description: String
                if isLastWorkInterval {
                    description = "WORK ends (Round \(round))"
                } else {
                    description = "WORK → REST (Round \(round))"
                }

                scheduleWakeUp(
                    identifier: "wakeup_set\(set)_round\(round)_work_to_rest",
                    timeInterval: scheduledTime,
                    message: "Set \(set), Round \(round) - Rest"
                )
                scheduleEntries.append((scheduledTime, startDate.addingTimeInterval(scheduledTime), description))
                notificationCount += 1

                // Schedule wake-up at end of rest interval (Rest → Work transition or end of set)
                // Skip for the last round of the last set
                if round < rounds || set < sets {
                    scheduledTime += TimeInterval(restDuration)
                    if round < rounds {
                        scheduleWakeUp(
                            identifier: "wakeup_set\(set)_round\(round)_rest_to_work",
                            timeInterval: scheduledTime,
                            message: "Set \(set), Round \(round + 1) - Work"
                        )
                        scheduleEntries.append((scheduledTime, startDate.addingTimeInterval(scheduledTime), "REST → WORK (Round \(round + 1))"))
                    } else {
                        // Last round of set, rest before next set
                        scheduleWakeUp(
                            identifier: "wakeup_set\(set)_rest_between_sets",
                            timeInterval: scheduledTime,
                            message: "Rest between sets"
                        )
                        scheduleEntries.append((scheduledTime, startDate.addingTimeInterval(scheduledTime), "REST → REST BETWEEN SETS"))
                    }
                    notificationCount += 1
                }
            }

            // Schedule wake-up at end of rest between sets (if not last set)
            if set < sets && restBetweenSets > 0 {
                scheduledTime += TimeInterval(restBetweenSets)
                scheduleWakeUp(
                    identifier: "wakeup_set\(set)_to_set\(set + 1)",
                    timeInterval: scheduledTime,
                    message: "Set \(set + 1) - Starting"
                )
                scheduleEntries.append((scheduledTime, startDate.addingTimeInterval(scheduledTime), "SET \(set + 1) starts"))
                notificationCount += 1
            }
        }

        // Print workout notification schedule
        printWorkoutSchedule(
            startDate: startDate,
            entries: scheduleEntries,
            workDuration: workDuration,
            restDuration: restDuration,
            rounds: rounds,
            sets: sets,
            countdownDuration: countdownDuration
        )

        print("BackgroundUpdateScheduler: Scheduled \(notificationCount) wake-up notifications")
    }

    /// Cancel all scheduled wake-up notifications
    func cancelAllWakeUps() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("BackgroundUpdateScheduler: Cancelled all wake-up notifications")
    }

    /// Schedule remaining wake-up notifications from current point (used after resume)
    /// - Parameters:
    ///   - timeRemainingInInterval: Time remaining in current interval
    ///   - currentState: Current timer state (work, rest, restBetweenSets)
    ///   - currentRound: Current round number (1-indexed)
    ///   - currentSet: Current set number (1-indexed)
    ///   - workDuration: Work interval duration in seconds
    ///   - restDuration: Rest interval duration in seconds
    ///   - rounds: Total number of rounds per set
    ///   - sets: Total number of sets
    ///   - restBetweenSets: Rest duration between sets in seconds
    func scheduleRemainingWakeUps(
        timeRemainingInInterval: TimeInterval,
        currentState: String,
        currentRound: Int,
        currentSet: Int,
        workDuration: Int,
        restDuration: Int,
        rounds: Int,
        sets: Int,
        restBetweenSets: Int
    ) {
        // Cancel any existing notifications first
        cancelAllWakeUps()

        var scheduledTime: TimeInterval = 0
        var notificationCount = 0

        // Start with time remaining in current interval
        scheduledTime = timeRemainingInInterval

        // Determine starting point based on current state
        var startRound = currentRound
        var startSet = currentSet
        var inWork = currentState == "WORK"
        var inRest = currentState == "REST"
        var inRestBetweenSets = currentState == "REST BETWEEN SETS"

        // Schedule notification for end of current interval
        if inWork {
            scheduleWakeUp(
                identifier: "wakeup_set\(startSet)_round\(startRound)_work_to_rest_resumed",
                timeInterval: scheduledTime,
                message: "Set \(startSet), Round \(startRound) - Rest"
            )
            notificationCount += 1
            // After this, we'll be in rest
            inWork = false
            inRest = true
        } else if inRest {
            // End of rest - either next round or end of set
            if startRound < rounds {
                scheduleWakeUp(
                    identifier: "wakeup_set\(startSet)_round\(startRound)_rest_to_work_resumed",
                    timeInterval: scheduledTime,
                    message: "Set \(startSet), Round \(startRound + 1) - Work"
                )
                startRound += 1
            } else if startSet < sets {
                scheduleWakeUp(
                    identifier: "wakeup_set\(startSet)_rest_between_sets_resumed",
                    timeInterval: scheduledTime,
                    message: "Rest between sets"
                )
                inRestBetweenSets = true
            }
            notificationCount += 1
            inRest = false
        } else if inRestBetweenSets {
            // End of rest between sets - start next set
            scheduleWakeUp(
                identifier: "wakeup_set\(startSet)_to_set\(startSet + 1)_resumed",
                timeInterval: scheduledTime,
                message: "Set \(startSet + 1) - Starting"
            )
            notificationCount += 1
            startSet += 1
            startRound = 1
            inRestBetweenSets = false
            inWork = true
        }

        // Now schedule remaining intervals
        for set in startSet...sets {
            let roundStart = (set == startSet) ? (inWork ? startRound : startRound + 1) : 1

            // Skip if roundStart exceeds rounds (can happen when resuming from REST on last round)
            guard roundStart <= rounds else {
                // Still need to schedule rest between sets if applicable
                if set < sets && restBetweenSets > 0 {
                    scheduledTime += TimeInterval(restBetweenSets)
                    scheduleWakeUp(
                        identifier: "wakeup_set\(set)_to_set\(set + 1)",
                        timeInterval: scheduledTime,
                        message: "Set \(set + 1) - Starting"
                    )
                    notificationCount += 1
                }
                continue
            }

            for round in roundStart...rounds {
                // Schedule work → rest transition
                if !(set == startSet && round == startRound && !inWork) {
                    scheduledTime += TimeInterval(workDuration)
                    scheduleWakeUp(
                        identifier: "wakeup_set\(set)_round\(round)_work_to_rest",
                        timeInterval: scheduledTime,
                        message: "Set \(set), Round \(round) - Rest"
                    )
                    notificationCount += 1
                }

                // Schedule rest → work transition (or rest between sets)
                if round < rounds || set < sets {
                    scheduledTime += TimeInterval(restDuration)
                    if round < rounds {
                        scheduleWakeUp(
                            identifier: "wakeup_set\(set)_round\(round)_rest_to_work",
                            timeInterval: scheduledTime,
                            message: "Set \(set), Round \(round + 1) - Work"
                        )
                    } else {
                        scheduleWakeUp(
                            identifier: "wakeup_set\(set)_rest_between_sets",
                            timeInterval: scheduledTime,
                            message: "Rest between sets"
                        )
                    }
                    notificationCount += 1
                }
            }

            // Schedule rest between sets
            if set < sets && restBetweenSets > 0 {
                scheduledTime += TimeInterval(restBetweenSets)
                scheduleWakeUp(
                    identifier: "wakeup_set\(set)_to_set\(set + 1)",
                    timeInterval: scheduledTime,
                    message: "Set \(set + 1) - Starting"
                )
                notificationCount += 1
            }
        }

        print("BackgroundUpdateScheduler: Scheduled \(notificationCount) remaining wake-up notifications")
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

    /// Print a formatted workout notification schedule to the console
    private func printWorkoutSchedule(
        startDate: Date,
        entries: [(offset: TimeInterval, wallClock: Date, description: String)],
        workDuration: Int,
        restDuration: Int,
        rounds: Int,
        sets: Int,
        countdownDuration: Int
    ) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let startTimeStr = timeFormatter.string(from: startDate)

        var lines: [String] = []
        lines.append("")
        lines.append("══════════════════════════════════════════")
        lines.append(" WORKOUT NOTIFICATION SCHEDULE")
        lines.append(" Start: \(startTimeStr) | \(workDuration)s work, \(restDuration)s rest, \(rounds) rounds" + (sets > 1 ? ", \(sets) sets" : ""))
        if countdownDuration > 0 {
            lines.append(" Countdown: \(countdownDuration)s (offset applied)")
        }
        lines.append("──────────────────────────────────────────")

        for entry in entries {
            let mins = Int(entry.offset) / 60
            let secs = Int(entry.offset) % 60
            let offsetStr = String(format: "+%02d:%02d", mins, secs)
            let wallStr = timeFormatter.string(from: entry.wallClock)
            lines.append(" \(offsetStr)  \(wallStr)  \(entry.description)")
        }

        lines.append("══════════════════════════════════════════")
        lines.append("")

        for line in lines {
            print(line)
        }
    }

    /// Schedule a single wake-up notification
    private func scheduleWakeUp(
        identifier: String,
        timeInterval: TimeInterval,
        message: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = "The Wolff Timer"
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
