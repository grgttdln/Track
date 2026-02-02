//
//  ToolbarChipButton.swift
//  Track
//

import SwiftUI

struct ToolbarChipButton: View {
    let title: String
    let systemName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemName)
                if !title.isEmpty {
                    Text(title)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        ToolbarChipButton(title: "View", systemName: "rectangle.grid.2x2") {}
        ToolbarChipButton(title: "Today", systemName: "calendar") {}
    }
    .padding()
}
