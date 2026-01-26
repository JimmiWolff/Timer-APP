//
//  TimerStateTests.swift
//  CircuitTimerTests
//
//  Unit tests for TimerState - state machine for timer lifecycle
//

import XCTest
@testable import CircuitTimer

final class TimerStateTests: XCTestCase {

    // MARK: - Display Name Tests

    func testDisplayName_idle_returnsReady() {
        XCTAssertEqual(TimerState.idle.displayName, "Ready")
    }

    func testDisplayName_work_returnsWORK() {
        XCTAssertEqual(TimerState.work.displayName, "WORK")
    }

    func testDisplayName_rest_returnsREST() {
        XCTAssertEqual(TimerState.rest.displayName, "REST")
    }

    func testDisplayName_restBetweenSets_returnsRESTBETWEENSETS() {
        XCTAssertEqual(TimerState.restBetweenSets.displayName, "REST BETWEEN SETS")
    }

    func testDisplayName_paused_returnsPAUSED() {
        XCTAssertEqual(TimerState.paused.displayName, "PAUSED")
    }

    func testDisplayName_finished_returnsCOMPLETE() {
        XCTAssertEqual(TimerState.finished.displayName, "COMPLETE")
    }

    // MARK: - Is Active Tests

    func testIsActive_idle_returnsFalse() {
        XCTAssertFalse(TimerState.idle.isActive)
    }

    func testIsActive_work_returnsTrue() {
        XCTAssertTrue(TimerState.work.isActive)
    }

    func testIsActive_rest_returnsTrue() {
        XCTAssertTrue(TimerState.rest.isActive)
    }

    func testIsActive_restBetweenSets_returnsTrue() {
        XCTAssertTrue(TimerState.restBetweenSets.isActive)
    }

    func testIsActive_paused_returnsFalse() {
        XCTAssertFalse(TimerState.paused.isActive)
    }

    func testIsActive_finished_returnsFalse() {
        XCTAssertFalse(TimerState.finished.isActive)
    }

    // MARK: - Can Pause Tests

    func testCanPause_idle_returnsFalse() {
        XCTAssertFalse(TimerState.idle.canPause)
    }

    func testCanPause_work_returnsTrue() {
        XCTAssertTrue(TimerState.work.canPause)
    }

    func testCanPause_rest_returnsTrue() {
        XCTAssertTrue(TimerState.rest.canPause)
    }

    func testCanPause_restBetweenSets_returnsTrue() {
        XCTAssertTrue(TimerState.restBetweenSets.canPause)
    }

    func testCanPause_paused_returnsFalse() {
        XCTAssertFalse(TimerState.paused.canPause)
    }

    func testCanPause_finished_returnsFalse() {
        XCTAssertFalse(TimerState.finished.canPause)
    }

    // MARK: - Can Resume Tests

    func testCanResume_idle_returnsFalse() {
        XCTAssertFalse(TimerState.idle.canResume)
    }

    func testCanResume_work_returnsFalse() {
        XCTAssertFalse(TimerState.work.canResume)
    }

    func testCanResume_rest_returnsFalse() {
        XCTAssertFalse(TimerState.rest.canResume)
    }

    func testCanResume_restBetweenSets_returnsFalse() {
        XCTAssertFalse(TimerState.restBetweenSets.canResume)
    }

    func testCanResume_paused_returnsTrue() {
        XCTAssertTrue(TimerState.paused.canResume)
    }

    func testCanResume_finished_returnsFalse() {
        XCTAssertFalse(TimerState.finished.canResume)
    }

    // MARK: - Can Reset Tests

    func testCanReset_idle_returnsFalse() {
        XCTAssertFalse(TimerState.idle.canReset)
    }

    func testCanReset_work_returnsTrue() {
        XCTAssertTrue(TimerState.work.canReset)
    }

    func testCanReset_rest_returnsTrue() {
        XCTAssertTrue(TimerState.rest.canReset)
    }

    func testCanReset_restBetweenSets_returnsTrue() {
        XCTAssertTrue(TimerState.restBetweenSets.canReset)
    }

    func testCanReset_paused_returnsTrue() {
        XCTAssertTrue(TimerState.paused.canReset)
    }

    func testCanReset_finished_returnsTrue() {
        XCTAssertTrue(TimerState.finished.canReset)
    }

    // MARK: - Codable Tests

    func testCodable_encodesAndDecodesCorrectly() throws {
        let states: [TimerState] = [.idle, .work, .rest, .restBetweenSets, .paused, .finished]

        for state in states {
            let encoder = JSONEncoder()
            let data = try encoder.encode(state)

            let decoder = JSONDecoder()
            let decoded = try decoder.decode(TimerState.self, from: data)

            XCTAssertEqual(decoded, state, "Failed for state: \(state)")
        }
    }

    // MARK: - Raw Value Tests

    func testRawValue_matchesExpected() {
        XCTAssertEqual(TimerState.idle.rawValue, "idle")
        XCTAssertEqual(TimerState.work.rawValue, "work")
        XCTAssertEqual(TimerState.rest.rawValue, "rest")
        XCTAssertEqual(TimerState.restBetweenSets.rawValue, "restBetweenSets")
        XCTAssertEqual(TimerState.paused.rawValue, "paused")
        XCTAssertEqual(TimerState.finished.rawValue, "finished")
    }
}
