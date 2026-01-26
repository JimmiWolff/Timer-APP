//
//  TimerEngineTests.swift
//  CircuitTimerTests
//
//  Unit tests for TimerEngine - core date-based timer logic
//

import XCTest
@testable import CircuitTimer

final class TimerEngineTests: XCTestCase {

    var sut: TimerEngine!

    override func setUpWithError() throws {
        sut = TimerEngine()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    // MARK: - Initial State Tests

    func testInitialState_isNotRunning() {
        XCTAssertFalse(sut.isRunning)
    }

    func testInitialState_isNotPaused() {
        XCTAssertFalse(sut.isPaused)
    }

    func testInitialState_timeRemainingIsZero() {
        XCTAssertEqual(sut.timeRemaining(), 0)
    }

    func testInitialState_intervalEndDateIsNil() {
        XCTAssertNil(sut.intervalEndDate)
    }

    // MARK: - Start Interval Tests

    func testStartInterval_setsIsRunningTrue() {
        sut.startInterval(duration: 30)
        XCTAssertTrue(sut.isRunning)
    }

    func testStartInterval_setsIntervalEndDate() {
        sut.startInterval(duration: 30)
        XCTAssertNotNil(sut.intervalEndDate)
    }

    func testStartInterval_timeRemainingApproximatelyEqualsDuration() {
        sut.startInterval(duration: 30)
        // Allow small delta for execution time
        XCTAssertEqual(sut.timeRemaining(), 30, accuracy: 0.1)
    }

    func testStartInterval_withZeroDuration_doesNotStart() {
        sut.startInterval(duration: 0)
        XCTAssertFalse(sut.isRunning)
    }

    func testStartInterval_withNegativeDuration_doesNotStart() {
        sut.startInterval(duration: -10)
        XCTAssertFalse(sut.isRunning)
    }

    // MARK: - Pause Tests

    func testPause_stopsRunning() {
        sut.startInterval(duration: 30)
        sut.pause()
        XCTAssertFalse(sut.isRunning)
    }

    func testPause_setsPausedTrue() {
        sut.startInterval(duration: 30)
        sut.pause()
        XCTAssertTrue(sut.isPaused)
    }

    func testPause_preservesTimeRemaining() {
        sut.startInterval(duration: 30)
        let timeBeforePause = sut.timeRemaining()
        sut.pause()
        XCTAssertEqual(sut.timeRemaining(), timeBeforePause, accuracy: 0.1)
    }

    func testPause_whenNotRunning_doesNothing() {
        sut.pause()
        XCTAssertFalse(sut.isPaused)
    }

    // MARK: - Resume Tests

    func testResume_setsRunningTrue() {
        sut.startInterval(duration: 30)
        sut.pause()
        sut.resume()
        XCTAssertTrue(sut.isRunning)
    }

    func testResume_setsPausedFalse() {
        sut.startInterval(duration: 30)
        sut.pause()
        sut.resume()
        XCTAssertFalse(sut.isPaused)
    }

    func testResume_setsNewIntervalEndDate() {
        sut.startInterval(duration: 30)
        sut.pause()
        // Wait a tiny bit so the new end date will be different
        Thread.sleep(forTimeInterval: 0.01)
        let timeBeforeResume = Date()
        sut.resume()
        // After resume, end date should be in the future (relative to when we resumed)
        XCTAssertNotNil(sut.intervalEndDate)
        XCTAssertGreaterThan(sut.intervalEndDate!, timeBeforeResume)
    }

    func testResume_whenNotPaused_doesNothing() {
        sut.resume()
        XCTAssertFalse(sut.isRunning)
    }

    // MARK: - Reset Tests

    func testReset_stopsRunning() {
        sut.startInterval(duration: 30)
        sut.reset()
        XCTAssertFalse(sut.isRunning)
    }

    func testReset_clearsPaused() {
        sut.startInterval(duration: 30)
        sut.pause()
        sut.reset()
        XCTAssertFalse(sut.isPaused)
    }

    func testReset_clearsIntervalEndDate() {
        sut.startInterval(duration: 30)
        sut.reset()
        XCTAssertNil(sut.intervalEndDate)
    }

    func testReset_setsTimeRemainingToZero() {
        sut.startInterval(duration: 30)
        sut.reset()
        XCTAssertEqual(sut.timeRemaining(), 0)
    }

    // MARK: - Has Interval Ended Tests

    func testHasIntervalEnded_whenNotRunning_returnsFalse() {
        XCTAssertFalse(sut.hasIntervalEnded())
    }

    func testHasIntervalEnded_whenJustStarted_returnsFalse() {
        sut.startInterval(duration: 30)
        XCTAssertFalse(sut.hasIntervalEnded())
    }

    func testHasIntervalEnded_whenIntervalPassed_returnsTrue() {
        // Start with very short duration that will have passed
        sut.startInterval(duration: 0.001)
        // Small delay to ensure interval has passed
        Thread.sleep(forTimeInterval: 0.01)
        XCTAssertTrue(sut.hasIntervalEnded())
    }

    // MARK: - Progress Tests

    func testProgress_atStart_isZero() {
        sut.startInterval(duration: 30)
        let progress = sut.progress(totalDuration: 30)
        XCTAssertEqual(progress, 0, accuracy: 0.05)
    }

    func testProgress_withZeroDuration_returnsZero() {
        let progress = sut.progress(totalDuration: 0)
        XCTAssertEqual(progress, 0)
    }

    func testProgress_isBetweenZeroAndOne() {
        sut.startInterval(duration: 30)
        let progress = sut.progress(totalDuration: 30)
        XCTAssertGreaterThanOrEqual(progress, 0)
        XCTAssertLessThanOrEqual(progress, 1)
    }

    // MARK: - Elapsed Time Tests

    func testElapsedTime_atStart_isZero() {
        sut.startInterval(duration: 30)
        let elapsed = sut.elapsedTime(totalDuration: 30)
        XCTAssertEqual(elapsed, 0, accuracy: 0.1)
    }
}
