//
//  RoundedPanel.swift
//  Track
//

import SwiftUI

struct RoundedPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.quaternary, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

            content
                .padding()
        }
    }
}

#Preview {
    RoundedPanel {
        Text("Content goes here")
    }
    .frame(width: 300, height: 200)
    .padding()
}
