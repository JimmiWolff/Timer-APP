//
//  TimerViewModelTests.swift
//  CircuitTimerTests
//
//  Unit tests for TimerViewModel - main orchestration layer
//

import XCTest
@testable import CircuitTimer

@MainActor
final class TimerViewModelTests: XCTestCase {

    var sut: TimerViewModel!

    override func setUpWithError() throws {
        sut = TimerViewModel()
    }

    override func tearDownWithError() throws {
        sut.reset()
        sut = nil
    }

    // MARK: - Initial State Tests

    func testInitialState_isIdle() {
        XCTAssertEqual(sut.state, .idle)
    }

    func testInitialState_timeRemainingIsZero() {
        XCTAssertEqual(sut.timeRemaining, 0)
    }

    func testInitialState_currentRoundIsOne() {
        XCTAssertEqual(sut.currentRound, 1)
    }

    func testInitialState_currentSetIsOne() {
        XCTAssertEqual(sut.currentSet, 1)
    }

    func testInitialState_progressIsZero() {
        XCTAssertEqual(sut.progress, 0)
    }

    // MARK: - Configuration Tests

    func testConfigure_withValidConfig_setsConfiguration() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        XCTAssertEqual(sut.totalRounds, 8)
    }

    func testConfigure_withMultipleSets_setsTotalSets() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8, sets: 3)
        sut.configure(config)
        XCTAssertEqual(sut.totalSets, 3)
    }

    func testConfigure_withInvalidConfig_doesNotCrash() {
        let config = TimerConfiguration(workTime: 0, restTime: 0, rounds: 0)
        sut.configure(config)
        // Should not crash, just log error
        XCTAssertEqual(sut.state, .idle)
    }

    // MARK: - Start Tests

    func testStart_withConfiguration_setsStateToWork() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        XCTAssertEqual(sut.state, .work)
    }

    func testStart_withConfiguration_setsTimeRemaining() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        // Force state update (normally done by UI timer)
        sut.synchronizeState()
        // timeRemaining should be close to 30 (allow for execution time)
        XCTAssertGreaterThan(sut.timeRemaining, 29)
        XCTAssertLessThanOrEqual(sut.timeRemaining, 30)
    }

    func testStart_withConfiguration_setsCurrentRoundToOne() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        XCTAssertEqual(sut.currentRound, 1)
    }

    func testStart_withoutConfiguration_remainsIdle() {
        sut.start()
        XCTAssertEqual(sut.state, .idle)
    }

    // MARK: - Pause Tests

    func testPause_whenWork_setsStateToPaused() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.pause()
        XCTAssertEqual(sut.state, .paused)
    }

    func testPause_whenIdle_remainsIdle() {
        sut.pause()
        XCTAssertEqual(sut.state, .idle)
    }

    func testPause_whenPaused_remainsPaused() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.pause()
        sut.pause() // Second pause
        XCTAssertEqual(sut.state, .paused)
    }

    // MARK: - Resume Tests

    func testResume_whenPaused_restoresPreviousState() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.pause()
        sut.resume()
        XCTAssertEqual(sut.state, .work)
    }

    func testResume_whenNotPaused_doesNothing() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.resume() // Should do nothing since we're in work state
        XCTAssertEqual(sut.state, .work)
    }

    // MARK: - Reset Tests

    func testReset_setsStateToIdle() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.reset()
        XCTAssertEqual(sut.state, .idle)
    }

    func testReset_setsCurrentRoundToOne() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.reset()
        XCTAssertEqual(sut.currentRound, 1)
    }

    func testReset_setsCurrentSetToOne() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8, sets: 3)
        sut.configure(config)
        sut.start()
        sut.reset()
        XCTAssertEqual(sut.currentSet, 1)
    }

    func testReset_setsTimeRemainingToZero() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.reset()
        XCTAssertEqual(sut.timeRemaining, 0)
    }

    func testReset_setsProgressToZero() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.reset()
        XCTAssertEqual(sut.progress, 0)
    }

    // MARK: - Computed Properties Tests

    func testCurrentStateText_matchesStateDisplayName() {
        XCTAssertEqual(sut.currentStateText, TimerState.idle.displayName)

        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        XCTAssertEqual(sut.currentStateText, TimerState.work.displayName)
    }

    func testFormattedTimeRemaining_formatsCorrectly() {
        let config = TimerConfiguration(workTime: 90, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        // Force state update (normally done by UI timer)
        sut.synchronizeState()
        // Should be around "01:29" or "01:30" (90 seconds = 1:30)
        XCTAssertTrue(sut.formattedTimeRemaining.hasPrefix("01:2") || sut.formattedTimeRemaining == "01:30",
                      "Expected time around 01:30, got \(sut.formattedTimeRemaining)")
    }

    func testFormattedTimeRemaining_atZero_showsZero() {
        XCTAssertEqual(sut.formattedTimeRemaining, "00:00")
    }

    // MARK: - Synchronize State Tests

    func testSynchronizeState_whenIdle_doesNothing() {
        sut.synchronizeState()
        XCTAssertEqual(sut.state, .idle)
    }

    func testSynchronizeState_whenPaused_remainsPaused() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.pause()
        sut.synchronizeState()
        XCTAssertEqual(sut.state, .paused)
    }

    // MARK: - State Transition Tests

    func testStateTransition_workCanPause() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        XCTAssertTrue(sut.state.canPause)
    }

    func testStateTransition_pausedCanResume() {
        let config = TimerConfiguration(workTime: 30, restTime: 10, rounds: 8)
        sut.configure(config)
        sut.start()
        sut.pause()
        XCTAssertTrue(sut.state.canResume)
    }

    func testStateTransition_idleCannotPause() {
        XCTAssertFalse(sut.state.canPause)
    }

    func testStateTransition_idleCannotResume() {
        XCTAssertFalse(sut.state.canResume)
    }
}
