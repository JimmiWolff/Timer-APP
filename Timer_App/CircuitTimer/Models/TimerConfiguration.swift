//
//  TimerConfiguration.swift
//  CircuitTimer
//
//  Configuration model for circuit training timer settings
//

import Foundation

/// Configuration for a circuit training workout
struct TimerConfiguration: Codable, Hashable {
    /// Work interval duration in seconds
    let workTime: Int

    /// Rest interval duration in seconds
    let restTime: Int

    /// Total number of rounds per set
    let rounds: Int

    /// Total number of sets
    let sets: Int

    /// Rest duration between sets in seconds
    let restBetweenSets: Int

    /// Initialize a timer configuration
    /// - Parameters:
    ///   - workTime: Duration of work intervals in seconds
    ///   - restTime: Duration of rest intervals in seconds
    ///   - rounds: Total number of rounds per set
    ///   - sets: Total number of sets (default: 1)
    ///   - restBetweenSets: Rest duration between sets in seconds (default: 0)
    init(workTime: Int, restTime: Int, rounds: Int, sets: Int = 1, restBetweenSets: Int = 0) {
        self.workTime = workTime
        self.restTime = restTime
        self.rounds = rounds
        self.sets = sets
        self.restBetweenSets = restBetweenSets
    }

    /// Check if configuration is valid
    var isValid: Bool {
        return workTime > 0 && restTime > 0 && rounds > 0 && sets > 0
    }

    /// Total workout duration in seconds (includes rest between sets, excludes rest after final round)
    var totalDuration: Int {
        let durationPerSet = (workTime + restTime) * rounds - restTime
        let totalRestBetweenSets = restBetweenSets * (sets - 1)
        return durationPerSet * sets + totalRestBetweenSets
    }
}

// MARK: - Example Configurations
extension TimerConfiguration {
    /// Quick 30-second work, 10-second rest, 8 rounds (classic Tabata style)
    static var tabata: TimerConfiguration {
        TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
    }

    /// 45-second work, 15-second rest, 10 rounds
    static var intermediate: TimerConfiguration {
        TimerConfiguration(workTime: 45, restTime: 15, rounds: 10)
    }

    /// 60-second work, 30-second rest, 6 rounds
    static var endurance: TimerConfiguration {
        TimerConfiguration(workTime: 60, restTime: 30, rounds: 6)
    }
}
