//
//  PlayPauseIcon.swift
//  Track
//

import SwiftUI

struct PlayPauseIcon: View {
    let isRunning: Bool

    private let pauseBarWidth: CGFloat = 4
    private let pauseBarHeight: CGFloat = 18
    private let pauseBarSpacing: CGFloat = 6

    private let playWidth: CGFloat = 14
    private let playHeight: CGFloat = 18

    var body: some View {
        Group {
            if isRunning {
                HStack(spacing: pauseBarSpacing) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .frame(width: pauseBarWidth, height: pauseBarHeight)
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .frame(width: pauseBarWidth, height: pauseBarHeight)
                }
                .foregroundStyle(.primary)
                .accessibilityLabel("Pause")
            } else {
                PlayTriangle()
                    .frame(width: playWidth, height: playHeight)
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Play")
            }
        }
    }
}

struct PlayTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    HStack(spacing: 20) {
        PlayPauseIcon(isRunning: true)
        PlayPauseIcon(isRunning: false)
    }
    .padding()
}
