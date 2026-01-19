//
//  CircularProgressView.swift
//  CircuitTimer
//
//  Circular progress ring component
//

import SwiftUI

/// Circular progress ring that shows workout progress
struct CircularProgressView: View {
    /// Progress value from 0.0 (start) to 1.0 (complete)
    let progress: Double

    /// Ring color
    var color: Color = .white

    /// Ring line width
    var lineWidth: CGFloat = Constants.Layout.progressLineWidth

    var body: some View {
        ZStack {
            // Background ring (dimmed) with glass effect
            Circle()
                .stroke(
                    color.opacity(0.2),
                    lineWidth: lineWidth
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

            // Progress ring (filled based on progress) with glow
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 0)
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.linear(duration: Constants.Animation.progressUpdate), value: progress)
        }
    }
}

// MARK: - Preview
#Preview("CircularProgressView") {
    VStack(spacing: 40) {
        CircularProgressView(progress: 0.0)
            .frame(width: 200, height: 200)

        CircularProgressView(progress: 0.25)
            .frame(width: 200, height: 200)

        CircularProgressView(progress: 0.5)
            .frame(width: 200, height: 200)

        CircularProgressView(progress: 0.75)
            .frame(width: 200, height: 200)

        CircularProgressView(progress: 1.0)
            .frame(width: 200, height: 200)
    }
    .padding()
    .background(Color.green)
}
