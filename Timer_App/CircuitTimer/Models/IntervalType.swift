//
//  IntervalType.swift
//  CircuitTimer
//
//  Type of interval (work or rest)
//

import Foundation

/// Type of timer interval
enum IntervalType: String, Codable, Hashable {
    /// Work interval
    case work

    /// Rest interval
    case rest

    /// Display name for the interval type
    var displayName: String {
        switch self {
        case .work:
            return "WORK"
        case .rest:
            return "REST"
        }
    }

    /// Opposite interval type
    var opposite: IntervalType {
        switch self {
        case .work:
            return .rest
        case .rest:
            return .work
        }
    }
}
