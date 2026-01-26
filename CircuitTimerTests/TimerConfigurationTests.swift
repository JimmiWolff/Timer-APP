//
//  TimerConfigurationTests.swift
//  CircuitTimerTests
//
//  Unit tests for TimerConfiguration - workout configuration model
//

import XCTest
@testable import CircuitTimer

final class TimerConfigurationTests: XCTestCase {

    // MARK: - Validation Tests

    func testIsValid_withValidConfig_returnsTrue() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        XCTAssertTrue(config.isValid)
    }

    func testIsValid_withZeroWorkTime_returnsFalse() {
        let config = TimerConfiguration(workTime: 0, restTime: 10, rounds: 8)
        XCTAssertFalse(config.isValid)
    }

    func testIsValid_withZeroRestTime_returnsFalse() {
        let config = TimerConfiguration(workTime: 30, restTime: 0, rounds: 8)
        XCTAssertFalse(config.isValid)
    }

    func testIsValid_withZeroRounds_returnsFalse() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 0)
        XCTAssertFalse(config.isValid)
    }

    func testIsValid_withNegativeWorkTime_returnsFalse() {
        let config = TimerConfiguration(workTime: -30, restTime: 10, rounds: 8)
        XCTAssertFalse(config.isValid)
    }

    func testIsValid_withMultipleSets_returnsTrue() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8, sets: 3, restBetweenSets: 60)
        XCTAssertTrue(config.isValid)
    }

    // MARK: - Total Duration Tests (Single Set)

    func testTotalDuration_singleRound_isWorkTimeOnly() {
        // 1 round = work time only (no rest after final round)
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 1)
        XCTAssertEqual(config.totalDuration, 30)
    }

    func testTotalDuration_twoRounds_includesOneRestPeriod() {
        // 2 rounds = work + rest + work = 30 + 10 + 30 = 70
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 2)
        XCTAssertEqual(config.totalDuration, 70)
    }

    func testTotalDuration_tabataStyle_calculatesCorrectly() {
        // 8 rounds of 30s work + 10s rest, minus final rest
        // = 8 * (30 + 10) - 10 = 320 - 10 = 310 seconds
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        XCTAssertEqual(config.totalDuration, 310)
    }

    // MARK: - Total Duration Tests (Multiple Sets)

    func testTotalDuration_multipleSets_calculatesCorrectly() {
        // 2 sets of 4 rounds (30s work + 10s rest), 60s rest between sets
        // Per set: 4 * (30 + 10) - 10 = 150 seconds
        // Total: 2 * 150 + 60 = 360 seconds
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 4, sets: 2, restBetweenSets: 60)
        XCTAssertEqual(config.totalDuration, 360)
    }

    func testTotalDuration_multipleSetsNoRestBetween_calculatesCorrectly() {
        // 3 sets of 2 rounds (30s work + 10s rest), no rest between sets
        // Per set: 2 * (30 + 10) - 10 = 70 seconds
        // Total: 3 * 70 + 0 = 210 seconds
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 2, sets: 3, restBetweenSets: 0)
        XCTAssertEqual(config.totalDuration, 210)
    }

    func testTotalDuration_singleSetWithRestBetweenSets_ignoresRestBetween() {
        // 1 set should not include any rest between sets
        // 4 rounds of 30s work + 10s rest = 4 * (30 + 10) - 10 = 150 seconds
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 4, sets: 1, restBetweenSets: 60)
        XCTAssertEqual(config.totalDuration, 150)
    }

    // MARK: - Default Values Tests

    func testDefaultValues_setsIsOne() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        XCTAssertEqual(config.sets, 1)
    }

    func testDefaultValues_restBetweenSetsIsZero() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        XCTAssertEqual(config.restBetweenSets, 0)
    }

    // MARK: - Preset Configuration Tests

    func testTabataPreset_hasCorrectValues() {
        let tabata = TimerConfiguration.tabata
        XCTAssertEqual(tabata.workTime, 30)
        XCTAssertEqual(tabata.restTime, 10)
        XCTAssertEqual(tabata.rounds, 8)
    }

    func testIntermediatePreset_hasCorrectValues() {
        let intermediate = TimerConfiguration.intermediate
        XCTAssertEqual(intermediate.workTime, 45)
        XCTAssertEqual(intermediate.restTime, 15)
        XCTAssertEqual(intermediate.rounds, 10)
    }

    func testEndurancePreset_hasCorrectValues() {
        let endurance = TimerConfiguration.endurance
        XCTAssertEqual(endurance.workTime, 60)
        XCTAssertEqual(endurance.restTime, 30)
        XCTAssertEqual(endurance.rounds, 6)
    }

    // MARK: - Codable Tests

    func testCodable_encodesAndDecodesCorrectly() throws {
        let original = TimerConfiguration(workTime: 45, restTime: 15, rounds: 10, sets: 2, restBetweenSets: 30)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TimerConfiguration.self, from: data)

        XCTAssertEqual(decoded.workTime, original.workTime)
        XCTAssertEqual(decoded.restTime, original.restTime)
        XCTAssertEqual(decoded.rounds, original.rounds)
        XCTAssertEqual(decoded.sets, original.sets)
        XCTAssertEqual(decoded.restBetweenSets, original.restBetweenSets)
    }

    // MARK: - Hashable Tests

    func testHashable_equalConfigsHaveSameHash() {
        let config1 = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        let config2 = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        XCTAssertEqual(config1.hashValue, config2.hashValue)
    }

    func testHashable_differentConfigsHaveDifferentHash() {
        let config1 = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        let config2 = TimerConfiguration(workTime: 45, restTime: 15, rounds: 10)
        XCTAssertNotEqual(config1.hashValue, config2.hashValue)
    }
}
