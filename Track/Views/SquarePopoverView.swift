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
    @State private var recentlyFinishedTasks: [TrackTask] = []
    @State private var showingDatePicker: Bool = false
    @State private var selectedDate: Date = .now

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
                    ToolbarChipButton(title: todayButtonTitle, systemName: "calendar") {
                        showingDatePicker.toggle()
                    }
                }
            }

            // Main panel area
            RoundedPanel {
                if showingDatePicker {
                    CalendarPickerView(selectedDate: $selectedDate) {
                        showingDatePicker = false
                    }
                } else if let task = activeTaskForSelectedDate {
                    ActiveTaskView(task: task, now: $now, timerRunning: $timerRunning) {
                        stop(task: task)
                    }
                    .onAppear { syncTimerState(for: task) }
                } else if !allCompletedTasks.isEmpty {
                    completedTasksList
                } else {
                    EmptyStatePanel()
                }
            }
            .frame(minHeight: 260)

            // Bottom input area styled like the screenshot (hidden when date picker is shown)
            if !showingDatePicker {
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

    // MARK: - Computed
    
    private var todayButtonTitle: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: selectedDate)
        }
    }

    /// Returns the effective date for a task (taskDate, or createdAt as fallback for legacy tasks)
    private func effectiveDate(for task: TrackTask) -> Date {
        // If taskDate is epoch (1970), it's likely a legacy task without taskDate set
        // Fall back to createdAt in that case
        let epoch = Date(timeIntervalSince1970: 0)
        let calendar = Calendar.current
        if calendar.isDate(task.taskDate, inSameDayAs: epoch) {
            return task.createdAt
        }
        return task.taskDate
    }
    
    private var activeTaskForSelectedDate: TrackTask? {
        let calendar = Calendar.current
        // First check if activeTask matches selected date
        if let task = activeTask,
           calendar.isDate(effectiveDate(for: task), inSameDayAs: selectedDate) {
            return task
        }
        // Otherwise find any active task for the selected date
        return tasks.first { task in
            task.isActive && calendar.isDate(effectiveDate(for: task), inSameDayAs: selectedDate)
        }
    }
    
    private var completedTasks: [TrackTask] {
        let calendar = Calendar.current
        return tasks.filter { task in
            task.isCompleted && !task.isActive &&
            calendar.isDate(effectiveDate(for: task), inSameDayAs: selectedDate)
        }
    }
    
    /// Combines recently finished tasks with queried completed tasks for immediate display
    private var allCompletedTasks: [TrackTask] {
        let calendar = Calendar.current
        var result: [TrackTask] = []
        // Add recently finished tasks that match the selected date and aren't yet in the query
        for task in recentlyFinishedTasks {
            let matchesDate = calendar.isDate(effectiveDate(for: task), inSameDayAs: selectedDate)
            let notInCompleted = !completedTasks.contains(where: { $0.id == task.id })
            if matchesDate && notInCompleted {
                result.append(task)
            }
        }
        result.append(contentsOf: completedTasks)
        return result
    }

    private var completedTasksList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(allCompletedTasks.enumerated()), id: \.element.id) { index, task in
                    completedTaskRow(task, index: index)
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func completedTaskRow(_ task: TrackTask, index: Int) -> some View {
        let category = TaskCategory(rawValue: task.taskType) ?? .unassigned
        
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                // Category pill and duration row
                HStack(spacing: 10) {
                    CategoryPill(category: category)

                    // Duration pill
                    Text(task.durationSeconds.formattedDuration)
                        .font(.system(.caption, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .strokeBorder(Color.primary.opacity(0.3), lineWidth: 1)
                        )

                    Spacer()
                }

                // Task description
                Text(task.descriptionText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
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
        // Find the active task for the selected date
        guard let task = activeTaskForSelectedDate else { return }
        // Only update duration if timer has a valid startedAt (not paused)
        if let start = task.startedAt {
            task.durationSeconds = Date().timeIntervalSince(start)
        }
    }

    // MARK: - Actions

    private func handleSubmit() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Create and start task with selected category and date
        let task = TrackTask(
            descriptionText: trimmed,
            taskType: selectedCategory.rawValue,
            taskDate: selectedDate,
            startedAt: Date(),
            isActive: true
        )
        context.insert(task)
        
        do {
            try context.save()
        } catch {
            print("Failed to save task: \(error)")
        }
        
        activeTask = task
        timerRunning = true
        inputText = ""
        selectedCategory = .unassigned // Reset for next task
        // Clean up recentlyFinishedTasks - remove any that are now in the query
        recentlyFinishedTasks.removeAll { finished in
            completedTasks.contains(where: { $0.id == finished.id })
        }
    }

    private func stop(task: TrackTask) {
        // Save final duration before stopping
        if let start = task.startedAt {
            task.durationSeconds = Date().timeIntervalSince(start)
        }
        task.isActive = false
        task.isCompleted = true
        task.endedAt = Date()
        task.startedAt = nil
        
        // Save to SwiftData
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
        
        // Store the finished task for immediate display, then clear active state
        recentlyFinishedTasks.insert(task, at: 0)
        timerRunning = false
        activeTask = nil
    }
}

#Preview {
    SquarePopoverView()
}

