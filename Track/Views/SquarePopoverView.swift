//
//  SquarePopoverView.swift
//  Track
//
//  Created by Georgette Dalen on 2/1/26.
//

import SwiftUI
import SwiftData
import Combine

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private extension Color {
    static var platformBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.gray.opacity(0.05)
        #endif
    }
}

struct SquarePopoverView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TrackTask.createdAt, order: .reverse) private var tasks: [TrackTask]

    @State private var inputText: String = ""
    @State private var selectedCategory: TaskCategory = .unassigned
    @State private var activeTask: TrackTask?
    @State private var now: Date = .now
    @State private var timerRunning: Bool = false

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {
            // Top-right controls
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    ToolbarChipButton(title: "View", systemName: "rectangle.grid.2x2") {
                        // TODO: handle View action
                    }
                    ToolbarChipButton(title: "Today", systemName: "calendar") {
                        // TODO: handle Today action
                    }
                }
            }

            // Main panel area
            RoundedPanel {
                if let task = activeTask ?? tasks.first(where: { $0.isActive }) {
                    ActiveTaskView(task: task, now: $now, timerRunning: $timerRunning) {
                        stop(task: task)
                    }
                    .onAppear { syncTimerState(for: task) }
                } else {
                    EmptyStatePanel()
                }
            }
            .frame(minHeight: 260)

            // Bottom input area styled like the screenshot
            VStack(alignment: .leading, spacing: 8) {
                // Styled text field
                RoundedTextField(text: $inputText, placeholder: "Type Task for Today")
                    .onSubmit { handleSubmit() }
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)

                // Styled category button placed under and aligned to the right
                HStack {
                    Spacer()
                    CategoryDropdownButton(selectedCategory: $selectedCategory)
                        .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(width: 520, height: 420)
        .onReceive(timer) { date in
            if timerRunning {
                now = date
                tickActive()
            }
        }
    }

    // MARK: - Timer

    private func syncTimerState(for task: TrackTask) {
        // Sync timerRunning with actual task state:
        // - Running: isActive AND has startedAt
        // - Paused: isActive but NO startedAt
        timerRunning = task.isActive && task.startedAt != nil
        activeTask = task
    }

    private func tickActive() {
        guard timerRunning else { return }
        // Find the active task (could be activeTask or from query)
        guard let task = activeTask ?? tasks.first(where: { $0.isActive }) else { return }
        // Only update duration if timer has a valid startedAt (not paused)
        if let start = task.startedAt {
            task.durationSeconds = Date().timeIntervalSince(start)
        }
    }

    // MARK: - Actions

    private func handleSubmit() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Create and start task with selected category
        let task = TrackTask(
            descriptionText: trimmed,
            taskType: selectedCategory.rawValue,
            startedAt: Date(),
            isActive: true
        )
        context.insert(task)
        try? context.save()
        
        activeTask = task
        timerRunning = true
        inputText = ""
        selectedCategory = .unassigned // Reset for next task
    }

    private func stop(task: TrackTask) {
        task.isActive = false
        task.endedAt = Date()
        timerRunning = false
        try? context.save()
    }
}

#Preview {
    SquarePopoverView()
}

