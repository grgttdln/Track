//
//  EmptyStatePanel.swift
//  Track
//

import SwiftUI

struct EmptyStatePanel: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.grid.2x2")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.tertiary)
            Text("No active task")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStatePanel()
        .frame(width: 300, height: 200)
}
